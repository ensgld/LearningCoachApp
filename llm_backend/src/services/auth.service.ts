// Authentication service
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { BadRequestError, ConflictError, NotFoundError } from '../common/errors';
import { jwtConfig } from '../config/jwt';
import { pool } from '../db/pool';

const SALT_ROUNDS = 10;

export interface User {
    id: string;
    email: string;
    displayName: string;
    isGuest: boolean;
    createdAt: Date;
}

export interface RegisterDTO {
    email: string;
    password: string;
    displayName: string;
}

export interface LoginDTO {
    email: string;
    password: string;
}

export interface AuthResponse {
    user: User;
    accessToken: string;
    refreshToken: string;
}

// Register new user
export async function registerUser(dto: RegisterDTO): Promise<AuthResponse> {
    const { email, password, displayName } = dto;

    // Log which database we're using
    const dbCheck = await pool.query('SELECT current_database() as db');
    console.log('🗄️  Registering user to database:', dbCheck.rows[0].db);
    console.log('👤 User data:', { email, displayName });

    // Check if user already exists
    const existingUser = await pool.query('SELECT id FROM users WHERE email = $1 AND deleted_at IS NULL', [email]);
    console.log('🔍 Duplicate check:', { email, exists: existingUser.rows.length > 0 });

    if (existingUser.rows.length > 0) {
        throw new ConflictError('Email already registered');
    }

    // Hash password
    const passwordHash = await bcrypt.hash(password, SALT_ROUNDS);

    // Insert user
    console.log('💾 Inserting user into database...');
    const result = await pool.query(
        `INSERT INTO users (email, display_name, is_guest, password_hash, created_at, updated_at)
     VALUES ($1, $2, $3, $4, NOW(), NOW())
     RETURNING id, email, display_name, is_guest, created_at`,
        [email, displayName, false, passwordHash]
    );
    console.log('✅ User inserted successfully:', { id: result.rows[0].id, rowCount: result.rowCount });

    const user = result.rows[0];

    // Generate tokens
    const { accessToken, refreshToken } = generateTokens(user.id, user.email);

    // Store refresh token hash
    const refreshTokenHash = await bcrypt.hash(refreshToken, SALT_ROUNDS);
    await pool.query('UPDATE users SET refresh_token_hash = $1 WHERE id = $2', [refreshTokenHash, user.id]);

    return {
        user: {
            id: user.id,
            email: user.email,
            displayName: user.display_name,
            isGuest: user.is_guest,
            createdAt: user.created_at,
        },
        accessToken,
        refreshToken,
    };
}

// Login user
export async function loginUser(dto: LoginDTO): Promise<AuthResponse> {
    const { email, password } = dto;

    // Find user
    const result = await pool.query(
        'SELECT id, email, display_name, is_guest, password_hash, created_at FROM users WHERE email = $1 AND deleted_at IS NULL',
        [email]
    );

    if (result.rows.length === 0) {
        throw new BadRequestError('Invalid email or password');
    }

    const user = result.rows[0];

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.password_hash);

    if (!isPasswordValid) {
        throw new BadRequestError('Invalid email or password');
    }

    // Generate tokens
    const { accessToken, refreshToken } = generateTokens(user.id, user.email);

    // Store refresh token hash
    const refreshTokenHash = await bcrypt.hash(refreshToken, SALT_ROUNDS);
    await pool.query('UPDATE users SET refresh_token_hash = $1, last_login_at = NOW() WHERE id = $2', [
        refreshTokenHash,
        user.id,
    ]);

    return {
        user: {
            id: user.id,
            email: user.email,
            displayName: user.display_name,
            isGuest: user.is_guest,
            createdAt: user.created_at,
        },
        accessToken,
        refreshToken,
    };
}

// Refresh access token
export async function refreshAccessToken(refreshToken: string): Promise<{ accessToken: string }> {
    try {
        const decoded = jwt.verify(refreshToken, jwtConfig.refreshTokenSecret) as { userId: string; email: string };

        // Verify refresh token in database
        const result = await pool.query(
            'SELECT id, email, refresh_token_hash FROM users WHERE id = $1 AND deleted_at IS NULL',
            [decoded.userId]
        );

        if (result.rows.length === 0) {
            throw new BadRequestError('Invalid refresh token');
        }

        const user = result.rows[0];
        const isTokenValid = await bcrypt.compare(refreshToken, user.refresh_token_hash);

        if (!isTokenValid) {
            throw new BadRequestError('Invalid refresh token');
        }

        // Generate new access token
        // @ts-ignore - JWT type compatibility issue
        const accessToken = jwt.sign(
            { userId: user.id, email: user.email },
            jwtConfig.accessTokenSecret as string,
            { expiresIn: jwtConfig.accessTokenExpiry }
        );

        return { accessToken };
    } catch (error) {
        if (error instanceof jwt.JsonWebTokenError) {
            throw new BadRequestError('Invalid refresh token');
        }
        throw error;
    }
}

// Get user profile
export async function getUserProfile(userId: string): Promise<User> {
    const result = await pool.query(
        'SELECT id, email, display_name, is_guest, created_at FROM users WHERE id = $1 AND deleted_at IS NULL',
        [userId]
    );

    if (result.rows.length === 0) {
        throw new NotFoundError('User not found');
    }

    const user = result.rows[0];
    return {
        id: user.id,
        email: user.email,
        displayName: user.display_name,
        isGuest: user.is_guest,
        createdAt: user.created_at,
    };
}

// Logout (invalidate refresh token)
export async function logoutUser(userId: string): Promise<void> {
    await pool.query('UPDATE users SET refresh_token_hash = NULL WHERE id = $1', [userId]);
}

// Helper: Generate JWT tokens
function generateTokens(userId: string, email: string) {
    // @ts-ignore - JWT type compatibility issue
    const accessToken = jwt.sign(
        { userId, email },
        jwtConfig.accessTokenSecret as string,
        { expiresIn: jwtConfig.accessTokenExpiry }
    );

    // @ts-ignore - JWT type compatibility issue
    const refreshToken = jwt.sign(
        { userId, email },
        jwtConfig.refreshTokenSecret as string,
        { expiresIn: jwtConfig.refreshTokenExpiry }
    );

    return { accessToken, refreshToken };
}

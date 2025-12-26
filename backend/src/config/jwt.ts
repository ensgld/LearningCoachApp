// JWT configuration
import { Secret } from 'jsonwebtoken';

export const jwtConfig = {
    accessTokenSecret: (process.env.JWT_ACCESS_SECRET || 'your-access-token-secret-change-in-production') as Secret,
    refreshTokenSecret: (process.env.JWT_REFRESH_SECRET || 'your-refresh-token-secret-change-in-production') as Secret,
    accessTokenExpiry: '15m',
    refreshTokenExpiry: '7d',
};

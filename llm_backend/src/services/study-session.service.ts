import { NotFoundError } from '../common/errors';
import { pool } from '../db/pool';

export interface CreateStudySessionDTO {
    goalId: string;
    durationMinutes: number;
    actualDurationSeconds?: number;
    quizScore?: number;
}

export async function createSession(userId: string, dto: CreateStudySessionDTO) {
    // Verify goal ownership
    const goalCheck = await pool.query(
        `SELECT id FROM goals WHERE id = $1 AND user_id = $2 AND deleted_at IS NULL`,
        [dto.goalId, userId]
    );

    if (goalCheck.rows.length === 0) {
        throw new NotFoundError('Goal not found');
    }

    const now = new Date();
    let startTime = now;
    let endTime = null;

    if (dto.actualDurationSeconds && dto.actualDurationSeconds > 0) {
        // If actual duration is provided, assume session is completed just now
        endTime = now;
        startTime = new Date(now.getTime() - dto.actualDurationSeconds * 1000);
    }

    const res = await pool.query(
        `INSERT INTO study_sessions (
            user_id, 
            goal_id, 
            duration_minutes, 
            actual_duration_seconds, 
            start_time,
            end_time
        )
        VALUES ($1, $2, $3, $4, $5, $6)
        RETURNING *`,
        [userId, dto.goalId, dto.durationMinutes, dto.actualDurationSeconds, startTime, endTime]
    );

    return res.rows[0];
}

export async function getSessions(userId: string) {
    const res = await pool.query(
        `SELECT * FROM study_sessions 
        WHERE user_id = $1 AND deleted_at IS NULL 
        ORDER BY created_at DESC`,
        [userId]
    );
    return res.rows;
}

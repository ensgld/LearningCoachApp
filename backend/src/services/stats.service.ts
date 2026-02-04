import { pool } from '../db/pool';

export interface UserStatsResult {
    currentLevel: number;
    currentXP: number;
    totalGold: number;
    avatarStage: string;
}

export interface UserProgressResult {
    totalStudyMinutes: number;
    completedSessions: number;
    averageScore: number; // For now keeping it, even if quiz removed, maybe future use or placeholder
}

export async function getUserStats(userId: string): Promise<UserStatsResult> {
    const res = await pool.query(
        `SELECT current_level, current_xp, total_gold, avatar_stage 
         FROM user_stats 
         WHERE user_id = $1`,
        [userId]
    );

    if (res.rows.length === 0) {
        // Create default stats if not exists (lazy init)
        const init = await pool.query(
            `INSERT INTO user_stats (user_id) VALUES ($1) 
             RETURNING current_level, current_xp, total_gold, avatar_stage`,
            [userId]
        );
        return {
            currentLevel: init.rows[0].current_level,
            currentXP: init.rows[0].current_xp,
            totalGold: init.rows[0].total_gold,
            avatarStage: init.rows[0].avatar_stage
        };
    }

    return {
        currentLevel: res.rows[0].current_level,
        currentXP: res.rows[0].current_xp,
        totalGold: res.rows[0].total_gold,
        avatarStage: res.rows[0].avatar_stage
    };
}

export async function getUserProgress(userId: string): Promise<UserProgressResult> {
    // Calculate aggregate study stats
    // We sum duration_seconds / 60 for minutes
    const res = await pool.query(
        `SELECT 
            COUNT(*) as sessions_count,
            COALESCE(SUM(actual_duration_seconds), 0) as total_seconds
         FROM study_sessions 
         WHERE user_id = $1 AND end_time IS NOT NULL`,
        [userId]
    );

    const row = res.rows[0];
    const totalMinutes = Math.round(parseInt(row.total_seconds) / 60);

    return {
        totalStudyMinutes: totalMinutes,
        completedSessions: parseInt(row.sessions_count),
        averageScore: 0 // Not tracked currently
    };
}

export interface DailyStatsResult {
    date: string;
    minutes: number;
    sessions: number;
}

export async function getDailyStats(userId: string): Promise<DailyStatsResult[]> {
    const res = await pool.query(
        `SELECT 
            TO_CHAR(start_time, 'YYYY-MM-DD') as study_date,
            COUNT(*) as sessions_count,
            COALESCE(SUM(actual_duration_seconds), 0) as total_seconds
         FROM study_sessions 
         WHERE user_id = $1 
           AND start_time > NOW() - INTERVAL '30 days'
           AND (actual_duration_seconds > 0 OR end_time IS NOT NULL)
         GROUP BY study_date
         ORDER BY study_date DESC`,
        [userId]
    );

    return res.rows.map(row => ({
        date: row.study_date,
        minutes: Math.round(parseInt(row.total_seconds) / 60),
        sessions: parseInt(row.sessions_count)
    }));
}

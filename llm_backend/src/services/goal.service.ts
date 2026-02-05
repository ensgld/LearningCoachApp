import { NotFoundError } from '../common/errors';
import { pool } from '../db/pool';

export interface CreateGoalDTO {
    title: string;
    description?: string;
    tasks?: { title: string }[];
}

export interface UpdateGoalDTO {
    title?: string;
    description?: string;
    status?: 'active' | 'completed';
}

export interface CreateTaskDTO {
    title: string;
}

export interface UpdateTaskDTO {
    title?: string;
    isCompleted?: boolean;
}

export async function createGoal(userId: string, dto: CreateGoalDTO) {
    const client = await pool.connect();
    try {
        await client.query('BEGIN');

        // 1. Create Goal
        const goalRes = await client.query(
            `INSERT INTO goals (user_id, title, description)
       VALUES ($1, $2, $3)
       RETURNING *`,
            [userId, dto.title, dto.description]
        );
        const goal = goalRes.rows[0];

        // 2. Create Tasks (if any)
        if (dto.tasks && dto.tasks.length > 0) {
            const taskValues = dto.tasks.map((t, i) => [
                goal.id,
                t.title,
                i // position
            ]);

            // Generate placeholders like ($1, $2, $3), ($4, $5, $6)...
            const placeholders = taskValues.map(
                (_, i) => `($${i * 3 + 1}, $${i * 3 + 2}, $${i * 3 + 3})`
            ).join(', ');

            const flatValues = taskValues.flat();

            await client.query(
                `INSERT INTO goal_tasks (goal_id, title, position)
         VALUES ${placeholders}`,
                flatValues
            );
        }

        await client.query('COMMIT');
        return getGoal(userId, goal.id);
    } catch (e) {
        await client.query('ROLLBACK');
        throw e;
    } finally {
        client.release();
    }
}

export async function getGoals(userId: string) {
    // Fetch goals with their tasks
    const goalsRes = await pool.query(
        `SELECT * FROM goals 
     WHERE user_id = $1 AND deleted_at IS NULL 
     ORDER BY created_at DESC`,
        [userId]
    );

    const goals = goalsRes.rows;

    // Assuming load is low, fetching tasks per goal or all at once.
    // For simplicity, let's fetch all tasks for these goals in one query
    if (goals.length === 0) return [];

    const goalIds = goals.map(g => g.id);
    const tasksRes = await pool.query(
        `SELECT * FROM goal_tasks 
     WHERE goal_id = ANY($1) AND deleted_at IS NULL 
     ORDER BY position ASC`,
        [goalIds]
    );

    const tasksByGoal = tasksRes.rows.reduce((acc, task) => {
        if (!acc[task.goal_id]) acc[task.goal_id] = [];
        acc[task.goal_id].push(task);
        return acc;
    }, {} as Record<string, any[]>);

    return goals.map(g => ({
        ...g,
        tasks: tasksByGoal[g.id] || []
    }));
}

export async function getGoal(userId: string, goalId: string) {
    const goalRes = await pool.query(
        `SELECT * FROM goals WHERE id = $1 AND user_id = $2 AND deleted_at IS NULL`,
        [goalId, userId]
    );

    if (goalRes.rows.length === 0) {
        throw new NotFoundError('Goal not found');
    }

    const tasksRes = await pool.query(
        `SELECT * FROM goal_tasks WHERE goal_id = $1 AND deleted_at IS NULL ORDER BY position ASC`,
        [goalId]
    );

    return {
        ...goalRes.rows[0],
        tasks: tasksRes.rows
    };
}

export async function updateGoal(userId: string, goalId: string, dto: UpdateGoalDTO) {
    // Verify ownership
    const goalCheck = await pool.query(
        `SELECT id FROM goals WHERE id = $1 AND user_id = $2 AND deleted_at IS NULL`,
        [goalId, userId]
    );
    if (goalCheck.rows.length === 0) throw new NotFoundError('Goal not found');

    const updates: string[] = [];
    const values: any[] = [];
    let idx = 1;

    if (dto.title !== undefined) {
        updates.push(`title = $${idx++}`);
        values.push(dto.title);
    }
    if (dto.description !== undefined) {
        updates.push(`description = $${idx++}`);
        values.push(dto.description);
    }
    if (dto.status !== undefined) {
        updates.push(`status = $${idx++}`);
        values.push(dto.status);
    }

    if (updates.length > 0) {
        values.push(goalId);
        await pool.query(
            `UPDATE goals SET ${updates.join(', ')} WHERE id = $${idx}`,
            values
        );
    }

    return getGoal(userId, goalId);
}

export async function deleteGoal(userId: string, goalId: string) {
    const result = await pool.query(
        `UPDATE goals SET deleted_at = NOW() WHERE id = $1 AND user_id = $2 AND deleted_at IS NULL RETURNING id`,
        [goalId, userId]
    );
    if (result.rows.length === 0) throw new NotFoundError('Goal not found');

    // Also soft delete tasks? Ideally yes, but schema might not CASCADE updates.
    // Manually soft delete tasks
    await pool.query(
        `UPDATE goal_tasks SET deleted_at = NOW() WHERE goal_id = $1`,
        [goalId]
    );
}

// --- Task Management ---

export async function addTask(userId: string, goalId: string, dto: CreateTaskDTO) {
    // Check ownership
    const goalCheck = await pool.query(
        `SELECT id FROM goals WHERE id = $1 AND user_id = $2 AND deleted_at IS NULL`,
        [goalId, userId]
    );
    if (goalCheck.rows.length === 0) throw new NotFoundError('Goal not found');

    // Get max position
    const posRes = await pool.query(
        `SELECT COALESCE(MAX(position), -1) as max_pos FROM goal_tasks WHERE goal_id = $1`,
        [goalId]
    );
    const nextPos = posRes.rows[0].max_pos + 1;

    await pool.query(
        `INSERT INTO goal_tasks (goal_id, title, position) VALUES ($1, $2, $3)`,
        [goalId, dto.title, nextPos]
    );

    await updateGoalProgress(goalId); // Recalculate progress

    return getGoal(userId, goalId);
}

export async function updateTask(userId: string, goalId: string, taskId: string, dto: UpdateTaskDTO) {
    // Check ownership via goal
    const goalCheck = await pool.query(
        `SELECT id FROM goals WHERE id = $1 AND user_id = $2 AND deleted_at IS NULL`,
        [goalId, userId]
    );
    if (goalCheck.rows.length === 0) throw new NotFoundError('Goal not found');

    const updates: string[] = [];
    const values: any[] = [];
    let idx = 1;

    if (dto.title !== undefined) {
        updates.push(`title = $${idx++}`);
        values.push(dto.title);
    }
    if (dto.isCompleted !== undefined) {
        updates.push(`is_completed = $${idx++}`);
        values.push(dto.isCompleted);
    }

    if (updates.length > 0) {
        values.push(taskId);
        values.push(goalId); // Ensure task belongs to goal
        await pool.query(
            `UPDATE goal_tasks SET ${updates.join(', ')} WHERE id = $${idx} AND goal_id = $${idx + 1} AND deleted_at IS NULL`,
            values
        );
    }

    if (dto.isCompleted !== undefined) {
        await updateGoalProgress(goalId);
    }

    return getGoal(userId, goalId);
}

export async function deleteTask(userId: string, goalId: string, taskId: string) {
    // Check ownership via goal
    const goalCheck = await pool.query(
        `SELECT id FROM goals WHERE id = $1 AND user_id = $2 AND deleted_at IS NULL`,
        [goalId, userId]
    );
    if (goalCheck.rows.length === 0) throw new NotFoundError('Goal not found');

    await pool.query(
        `UPDATE goal_tasks SET deleted_at = NOW() WHERE id = $1 AND goal_id = $2`,
        [taskId, goalId]
    );

    await updateGoalProgress(goalId);

    return getGoal(userId, goalId);
}

async function updateGoalProgress(goalId: string) {
    const res = await pool.query(
        `SELECT 
       COUNT(*) as total, 
       COUNT(*) FILTER (WHERE is_completed = true) as completed
     FROM goal_tasks 
     WHERE goal_id = $1 AND deleted_at IS NULL`,
        [goalId]
    );

    const { total, completed } = res.rows[0];
    const progress = total == 0 ? 0 : Number(completed) / Number(total);

    await pool.query(
        `UPDATE goals SET progress = $1 WHERE id = $2`,
        [progress, goalId]
    );
}

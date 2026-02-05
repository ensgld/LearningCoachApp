// Application entry point
import app from './app';
import { config } from './config/env';
import { closeDatabasePool } from './db/pool';

const PORT = config.PORT;

const server = app.listen(PORT, () => {
    console.log(`🚀 Server running on http://localhost:${PORT}`);
    console.log(`📊 Environment: ${config.NODE_ENV}`);
    console.log(`🗄️  Database: ${config.DATABASE_URL.replace(/:[^:]*@/, ':****@')}`); // Hide password
    console.log(`✅ Health check: http://localhost:${PORT}/api/v1/health`);
});

// Graceful shutdown
process.on('SIGTERM', async () => {
    console.log('SIGTERM signal received: closing HTTP server');
    server.close(async () => {
        console.log('HTTP server closed');
        await closeDatabasePool();
        process.exit(0);
    });
});

process.on('SIGINT', async () => {
    console.log('\nSIGINT signal received: closing HTTP server');
    server.close(async () => {
        console.log('HTTP server closed');
        await closeDatabasePool();
        process.exit(0);
    });
});

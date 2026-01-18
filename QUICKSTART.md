# Quick Start Guide

Get up and running with the Idea Board application in 5 minutes!

## Local Development (Fastest Way)

```bash
# 1. Navigate to project directory
cd idea-board

# 2. Start all services
docker compose up --build

# 3. Open your browser
# Frontend: http://localhost:3000
# Backend API: http://localhost:8000
# API Docs: http://localhost:8000/docs
```

That's it! The application is now running locally.

## Testing the Application

1. Open http://localhost:3000
2. Enter an idea in the text box
3. Click "Submit Idea"
4. Your idea should appear in the list below

## Stopping the Application

Press `Ctrl+C` in the terminal, then:

```bash
docker-compose down
```

## Next Steps

- **Deploy to Cloud**: See `DEPLOYMENT.md`
- **Understand Architecture**: See `README.md`
- **Project Overview**: See `PROJECT_SUMMARY.md`

## Troubleshooting

**Port already in use?**
- Change ports in `docker-compose.yml`

**Database connection error?**
- Wait a few seconds for PostgreSQL to start
- Check logs: `docker-compose logs postgres`

**Frontend not loading?**
- Check backend is running: `docker-compose logs backend`
- Verify API URL in frontend environment

## What's Next?

1. ✅ Local development (you just did this!)
2. 📦 Deploy to AWS or GCP
3. 🤖 Set up AI features
4. 🚀 Use CI/CD pipeline

Happy coding! 🎉


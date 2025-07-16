# Life Link - Azure Deployment Guide

## Pre-deployment Checklist

### Required Azure Resources
- Azure Subscription with sufficient quota
- Resource Group (will be created by AZD)
- Azure Container Registry (managed by Bicep)
- Azure Cosmos DB for MongoDB API (managed by Bicep)
- Azure Key Vault (managed by Bicep)
- Azure Container Apps (managed by Bicep)
- Azure Static Web Apps (managed by Bicep)

### Required Environment Variables
Create these environment variables before deployment:

#### Required Secrets
- `JWT_SECRET`: Secret key for JWT tokens
- `GEMINI_API_KEY`: Google Gemini AI API key
- `SESSION_SECRET`: Express session secret
- `STRIPE_SECRET_KEY`: Stripe payment secret key (optional)
- `CLOUDINARY_CLOUD_NAME`: Cloudinary cloud name
- `CLOUDINARY_API_KEY`: Cloudinary API key
- `CLOUDINARY_API_SECRET`: Cloudinary API secret

## Deployment Steps

### 1. Install Azure Developer CLI
```bash
# Windows (using winget)
winget install microsoft.azd

# Or visit: https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd
```

### 2. Login to Azure
```bash
azd auth login
```

### 3. Initialize the Project
```bash
azd init
```

### 4. Set Environment Variables
```bash
azd env set JWT_SECRET "your_jwt_secret_here"
azd env set GEMINI_API_KEY "your_gemini_api_key_here"
azd env set SESSION_SECRET "your_session_secret_here"
azd env set CLOUDINARY_CLOUD_NAME "your_cloudinary_cloud_name"
azd env set CLOUDINARY_API_KEY "your_cloudinary_api_key"
azd env set CLOUDINARY_API_SECRET "your_cloudinary_api_secret"
# Optional:
azd env set STRIPE_SECRET_KEY "your_stripe_secret_key"
```

### 5. Deploy to Azure
```bash
azd up
```

## Architecture Overview

### Backend (Container App)
- **Technology**: Node.js, Express.js
- **Database**: Azure Cosmos DB (MongoDB API)
- **File Storage**: Cloudinary
- **AI**: Google Gemini AI
- **Authentication**: JWT tokens
- **Hosting**: Azure Container Apps

### Frontend (Static Web App)
- **Technology**: React, Vite
- **Routing**: React Router
- **Styling**: Tailwind CSS
- **State**: React Context
- **Hosting**: Azure Static Web Apps

### Admin Panel (Static Web App)
- **Technology**: React, Vite
- **Features**: Doctor management, appointments
- **Authentication**: JWT tokens
- **Hosting**: Azure Static Web Apps

## Key Features
- **Patient Management**: Registration, profiles, appointments
- **Doctor Management**: Profiles, schedules, appointment handling
- **AI Chat Interface**: Medical consultation using Google Gemini
- **Payment Integration**: Stripe payment processing (optional)
- **File Uploads**: Medical documents via Cloudinary
- **Admin Dashboard**: System administration

## Security Features
- Environment-based configuration
- JWT-based authentication
- HTTPS-only communication
- Azure Key Vault for secrets management
- CORS protection
- Input validation

## Monitoring & Logging
- Azure Application Insights
- Azure Log Analytics
- Container Apps logging
- Database monitoring

## Post-Deployment Configuration

### 1. Update CORS Settings
After deployment, update the backend CORS configuration with your actual domain names:

```javascript
// In backend/server.js, update the CORS origins
app.use(cors({
  origin: [
    'https://your-frontend-domain.azurestaticapps.net',
    'https://your-admin-domain.azurestaticapps.net'
  ],
  credentials: true
}));
```

### 2. Frontend Environment Variables
Update your Static Web App configuration with the backend URL:

```bash
# Get the backend URL from deployment output
azd env get-values

# Update frontend environment variables via Azure portal
# VITE_BACKEND_URL=https://your-backend-url.azurecontainerapps.io
```

## Troubleshooting

### Common Issues
1. **Build Failures**: Check Node.js version (should be 20+)
2. **Database Connection**: Verify Cosmos DB connection string
3. **CORS Errors**: Update frontend URLs in backend CORS config
4. **Environment Variables**: Ensure all required variables are set

### Useful Commands
```bash
# Check deployment status
azd show

# View logs
azd logs

# Update environment
azd deploy

# Clean up resources
azd down
```

## Development Setup

### Local Development
1. Install dependencies: `npm install` in each folder
2. Copy `.env.template` to `.env` and fill in values
3. Start MongoDB locally or use Cosmos DB connection
4. Run services:
   - Backend: `npm run server` (port 4000)
   - Frontend: `npm run dev` (port 5173)
   - Admin: `npm run dev` (port 5174)

### Testing
```bash
# Backend tests
cd backend && npm test

# Frontend tests  
cd frontend && npm test

# Admin tests
cd admin && npm test
```

## Support
For issues and questions:
1. Check Azure documentation
2. Review application logs
3. Check environment variables
4. Verify API endpoints

#!/bin/bash

# Script to create FlashPass API documentation repository in the organization

echo "Setting up FlashPass API Documentation repository..."

# Initialize git repository
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: FlashPass External API Documentation

- Added comprehensive API documentation for external endpoints
- Configured GitHub Pages with Jekyll
- Included authentication, menu access, and credit line endpoints
- Added Node.js integration examples"

# Instructions for manual setup
echo ""
echo "=== Manual Steps Required ==="
echo ""
echo "1. Go to https://github.com/organizations/FlashPass-Team/repositories/new"
echo "2. Create a new repository with these settings:"
echo "   - Repository name: api-documentation"
echo "   - Description: Public API documentation for FlashPass external endpoints"
echo "   - Public repository"
echo "   - Do NOT initialize with README (we already have one)"
echo ""
echo "3. After creating, run these commands:"
echo "   git remote add origin https://github.com/FlashPass-Team/api-documentation.git"
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""
echo "4. Enable GitHub Pages:"
echo "   - Go to Settings > Pages"
echo "   - Source: Deploy from a branch"
echo "   - Branch: main"
echo "   - Folder: /docs"
echo "   - Click Save"
echo ""
echo "5. Your documentation will be available at:"
echo "   https://flashpass-team.github.io/api-documentation/"
echo ""
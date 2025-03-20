#!/bin/bash

# Define the deployment file path
DEPLOYMENT_FILE="manifests/application.yaml"

# Check if the file exists
if [ ! -f "$DEPLOYMENT_FILE" ]; then
    echo "❌ ERROR: $DEPLOYMENT_FILE not found! Make sure you're in the correct directory."
    exit 1
fi

# Detect current version in application.yaml (ignores comments)
CURRENT_VERSION=$(grep "image: torpoly/flask-rpol:" "$DEPLOYMENT_FILE" | awk -F ':' '{print $NF}' | tr -d '[:space:]')

# Validate extracted version
if [[ "$CURRENT_VERSION" != "v1" && "$CURRENT_VERSION" != "v2" ]]; then
    echo "❌ ERROR: Unexpected image version found: '$CURRENT_VERSION'"
    exit 1
fi

# Determine new version
if [ "$CURRENT_VERSION" == "v1" ]; then
    NEW_VERSION="v2"
else
    NEW_VERSION="v1"
fi

# Print the version change
echo "🔄 Switching from version $CURRENT_VERSION to $NEW_VERSION in $DEPLOYMENT_FILE"

# Update the version in application.yaml
sed -i "s|image: torpoly/flask-rpol:$CURRENT_VERSION|image: torpoly/flask-rpol:$NEW_VERSION|g" "$DEPLOYMENT_FILE"

# Confirm the change
echo "✅ Updated application.yaml:"
grep "image: torpoly/flask-rpol:" "$DEPLOYMENT_FILE"

# Git commit and push
echo "📤 Committing and pushing changes to GitHub..."
git add "$DEPLOYMENT_FILE"
git commit -m "Updated deployment image to $NEW_VERSION"
git push

# Confirm the push
if [ $? -eq 0 ]; then
    echo "🚀 Successfully pushed changes to GitHub!"
else
    echo "❌ ERROR: Failed to push changes. Check your GitHub credentials."
    exit 1
fi

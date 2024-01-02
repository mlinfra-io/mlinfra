set -e

echo "Switching to platinfra.github.io directory..."
if cd ../platinfra.github.io; then
    echo "Deploying documentation to GitHub Pages..."
    if ! mkdocs gh-deploy --config-file ../platinfra/mkdocs.yml --remote-branch main; then
        echo "Deployment failed."
        exit 1
    fi
    echo "Switching back to platinfra directory..."
    if cd ../platinfra; then
        echo "Deployment completed successfully."
    else
        echo "Failed to switch back to platinfra directory."
        exit 1
    fi
else
    echo "Failed to switch to platinfra.github.io directory."
    exit 1
fi

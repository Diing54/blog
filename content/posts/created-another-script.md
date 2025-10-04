+++
date = '2025-10-04T14:07:04+03:00'
draft = false
title = 'Created Another Script'
tags = ["Automation","Bash","linux"]
+++
Another day creating another automation, it may not be a complex one but still its an automation. Today I created another simple beautiful script that automates my blogging workflow. Instead of manually navigating to my Hugo directory and running commands, I can create a new post from anywhere in my system by just running the custom command "blog".
**How it works**
- Run `blog` from the command line
- Enter your blog title
- The scripts automatically generates a file using Hugo's archetype template. The file's name is the title provided
- It then opens the file automatically in Neovim for editing

**The script:**

```bash
#!/bin/bash
BLOG_DIR="$HOME/blog"
cd "$BLOG_DIR"
read -p "Enter post title: " title
filename=$(echo "$title" | tr '[:upper:]' '[:lower:]' ' ' '-' | sed 's/[^a-z0-9-]//g')
hugo new "posts/${filename}.md"
nvim "content/posts/${filename}.md"
```

### References

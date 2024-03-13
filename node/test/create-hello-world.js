const fs = require('fs');
const path = require('path');

const projectDirectory = '@itc-infra/hello-world';

// 创建项目目录（确保递归创建目录）
fs.mkdirSync(projectDirectory, { recursive: true });

// 创建 package.json 文件
const packageJsonContent = {
  name: '@itc-infra/hello-world',
  version: '1.0.0',
  description: 'A simple hello-world project',
  main: 'index.js',
  scripts: {
    start: 'node index.js'
  },
  keywords: ['hello-world'],
  author: 'Your Name',
  license: 'MIT'
};

fs.writeFileSync(path.join(projectDirectory, 'package.json'), JSON.stringify(packageJsonContent, null, 2));

// 创建 index.js 文件
const indexJsContent = 'console.log("Hello, World!");';

fs.writeFileSync(path.join(projectDirectory, 'index.js'), indexJsContent);

console.log('hello-world project created successfully!');

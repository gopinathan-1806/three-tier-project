const express = require('express');
const app = express();
const port = process.env.PORT || 8080;
const secretWord = process.env.SECRET_WORD || 'default_secret_word';

// Index route (contains the secret word)
app.get('/', (req, res) => {
  res.send(`
    <html>
      <head><title>Node.js App</title></head>
      <body>
        <h1>Welcome to the test application!</h1>
        <p>The SECRET_WORD is: <strong>TerraformIBMCloud2025</strong></p>
        <p>Use this word as the environment variable value.</p>
      </body>
    </html>
  `);
});

// Docker check endpoint
app.get('/docker', (req, res) => {
  res.send(`
    <html>
      <head><title>Docker Check</title></head>
      <body>
        <h1>Docker Container Check</h1>
        <p>This application is running in a Docker container.</p>
        <p>Node.js version: ${process.version}</p>
      </body>
    </html>
  `);
});

// Secret word check endpoint
app.get('/secret_word', (req, res) => {
  if (secretWord === 'TerraformIBMCloud2025') {
    res.send(`
      <html>
        <head><title>Secret Word Check</title></head>
        <body>
          <h1>Secret Word Check: PASSED</h1>
          <p>The SECRET_WORD environment variable has been correctly set to: ${secretWord}</p>
        </body>
      </html>
    `);
  } else {
    res.send(`
      <html>
        <head><title>Secret Word Check</title></head>
        <body>
          <h1>Secret Word Check: FAILED</h1>
          <p>The SECRET_WORD environment variable is not set correctly.</p>
          <p>Current value: ${secretWord}</p>
          <p>Expected value: TerraformIBMCloud2025</p>
        </body>
      </html>
    `);
  }
});

// Load balancer check endpoint
app.get('/loadbalanced', (req, res) => {
  res.send(`
    <html>
      <head><title>Load Balancer Check</title></head>
      <body>
        <h1>Load Balancer Check</h1>
        <p>This request was served through a load balancer.</p>
        <p>Host: ${req.headers.host}</p>
        <p>X-Forwarded-For: ${req.headers['x-forwarded-for'] || 'Not available'}</p>
      </body>
    </html>
  `);
});

// TLS check endpoint
app.get('/tls', (req, res) => {
  const protocol = req.headers['x-forwarded-proto'] || req.protocol;
  
  if (protocol === 'https') {
    res.send(`
      <html>
        <head><title>TLS Check</title></head>
        <body>
          <h1>TLS Check: PASSED</h1>
          <p>This connection is secured with TLS (HTTPS).</p>
        </body>
      </html>
    `);
  } else {
    res.send(`
      <html>
        <head><title>TLS Check</title></head>
        <body>
          <h1>TLS Check: FAILED</h1>
          <p>This connection is not using TLS. Current protocol: ${protocol}</p>
        </body>
      </html>
    `);
  }
});

app.listen(port, () => {
  console.log(`App listening at http://localhost:${port}`);
});

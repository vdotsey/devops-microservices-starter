// const express = require('express');
// const app = express();
// app.use(express.json());

// app.get('/auth/health', (req, res) => {
//   res.send({ status: 'auth service running' });
// });

// app.post('/auth/login', (req, res) => {
//   const { username, password } = req.body;
//   // fake login logic
//   res.send({ token: 'fake-jwt-token', user: username });
// });

// app.listen(3000, () => console.log('Auth service on port 3000'));


const express = require('express');
const client = require('prom-client');
const app = express();
app.use(express.json());

// Collect default Prometheus metrics
const collectDefaultMetrics = client.collectDefaultMetrics;
collectDefaultMetrics(); // This will expose memory, CPU, event loop, etc.

// Expose /metrics endpoint
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', client.register.contentType);
  res.send(await client.register.metrics());
});

// Health check endpoint
app.get('/auth/health', (req, res) => {
  res.send({ status: 'auth service running' });
});

// Login endpoint
app.post('/auth/login', (req, res) => {
  const { username, password } = req.body;
  // fake login logic
  res.send({ token: 'fake-jwt-token', user: username });
});

// Start the server
app.listen(3000, () => console.log('Auth service on port 3000'));

// const express = require('express');
// const app = express();
// app.use(express.json());

// const products = [
//   { id: 1, name: 'Keyboard' },
//   { id: 2, name: 'Monitor' }
// ];

// app.get('/products', (req, res) => {
//   res.send(products);
// });

// app.listen(3001, () => console.log('Products service on port 3001'));


const express = require('express');
const client = require('prom-client');
const app = express();
app.use(express.json());

// Prometheus metrics setup
const collectDefaultMetrics = client.collectDefaultMetrics;
collectDefaultMetrics();

const productsRequestCounter = new client.Counter({
  name: 'products_requests_total',
  help: 'Total number of requests to /products',
});

const products = [
  { id: 1, name: 'Keyboard' },
  { id: 2, name: 'Monitor' }
];

// GET /products — list products
app.get('/products', (req, res) => {
  productsRequestCounter.inc(); // increment metric
  res.send(products);
});

// GET /metrics — Prometheus endpoint
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', client.register.contentType);
  res.send(await client.register.metrics());
});

// Start the server
app.listen(3001, () => console.log('Products service on port 3001'));

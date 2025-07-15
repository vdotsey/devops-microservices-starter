// const express = require('express');
// const app = express();
// app.use(express.json());

// let orders = [];

// app.post('/orders', (req, res) => {
//   const order = req.body;
//   orders.push(order);
//   res.status(201).send(order);
// });

// app.get('/orders', (req, res) => {
//   res.send(orders);
// });

// app.listen(3002, () => console.log('Orders service on port 3002'));


const express = require('express');
const client = require('prom-client');
const app = express();
app.use(express.json());

// Prometheus metrics
const collectDefaultMetrics = client.collectDefaultMetrics;
collectDefaultMetrics();

const orderCounter = new client.Counter({
  name: 'orders_created_total',
  help: 'Total number of orders created',
});

const orders = [];

// POST /orders — create order
app.post('/orders', (req, res) => {
  const order = req.body;
  orders.push(order);
  orderCounter.inc(); // increment metric
  res.status(201).send(order);
});

// GET /orders — list orders
app.get('/orders', (req, res) => {
  res.send(orders);
});

// GET /metrics — Prometheus scrape endpoint
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', client.register.contentType);
  res.send(await client.register.metrics());
});

// Start the server
app.listen(3002, () => console.log('Orders service on port 3002'));

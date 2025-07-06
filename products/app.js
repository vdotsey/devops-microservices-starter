const express = require('express');
const app = express();
app.use(express.json());

const products = [
  { id: 1, name: 'Keyboard' },
  { id: 2, name: 'Monitor' }
];

app.get('/products', (req, res) => {
  res.send(products);
});

app.listen(3001, () => console.log('Products service on port 3001'));

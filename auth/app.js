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
const app = express();
app.use(express.json());

app.get('/health', (req, res) => {
  res.send({ status: 'auth service running' });
});

app.post('/login', (req, res) => {
  const { username, password } = req.body;
  res.send({ token: 'fake-jwt-token', user: username });
});

app.listen(3000, () => console.log('Auth service on port 3000'));

const express = require('express');
const app = express();
const port = 3000;
app.get('/', (req, res) => {
  res.json({
    message: "Despliegue Blue-Green Exitoso",
    host: process.env.HOSTNAME,
    color: process.env.NEW_COLOR || "unknown",
    version: "3.0.0"
  });
});
app.listen(port, () => {
  console.log(`App en puerto ${port}`);
});

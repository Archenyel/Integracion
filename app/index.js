const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.json({
    message: "Despliegue Blue-Green Exitoso",
    host: process.env.HOSTNAME,
    color: process.env.COLOR || "unknown",
    version: "1.0.0" // Cambia esto para probar que se actualiza
  });
});

app.listen(port, () => {
  console.log(`App en puerto ${port}`);
});
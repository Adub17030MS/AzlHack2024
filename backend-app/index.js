// Import required modules
const express = require('express');
const { exec } = require('child_process');
const path = require('path');

// Create an instance of Express
const app = express();

// Define a route
app.get('/', (req, res) => {
    res.send('Hello, World!');
});


// Define a route to run the Bash script
app.get('/run-script', (req, res) => {
    const scriptPath = path.join(__dirname, 'provisioning/provision-vm.sh');
    
    // Execute the Bash script
    exec(scriptPath, (error, stdout, stderr) => {
      if (error) {
        console.error(`Error executing script: ${error.message}`);
        return res.status(500).send(`Error executing script: ${error.message}`);
      }
  
      if (stderr) {
        console.error(`Script error output: ${stderr}`);
        return res.status(500).send(`Script error output: ${stderr}`);
      }
  
      console.log(`Script output: ${stdout}`);
      res.send(`Script output: ${stdout}`);
    });
  });
// Start the server
const port = process.env.PORT || 3000; // Use the PORT environment variable if available, otherwise use port 3000
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});

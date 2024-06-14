// Import required modules
const express = require('express');
const { exec } = require('child_process');
const path = require('path');
const cors = require('cors');

// Create an instance of Express
const app = express();

// Use CORS middleware
app.use(cors());

// Define base route
// Define a route
app.get('/', (req, res) => {
  res.json({ message: 'Hello, World!' });
});

// Define a route to run the Bash script
app.get('/provision-build-sandbox', (req, res) => {
    const scriptPath = path.join(__dirname, 'provisioning/provision-vm.sh post-provision-BuildEnv.sh');
    
    // Execute the Bash script
    exec(scriptPath, (error, stdout, stderr) => {
      if (error) {
        console.error(`Error executing script: ${error.message}`);
        return res.status(500).send(`Error executing script: ${error.message}`);
      }
  
      console.log(`Script output: ${stdout}`);
      // if (stderr) {
      //   console.error(`Script error output: ${stderr}`);
      //   return res.status(500).send(`Script error output: ${stderr}`);
      // }
  
      // res.json(`Script output: ${stdout}`);
      return res.status(200).json({ message: stdout });

    });
  });

// Start the server
const port = process.env.PORT || 3000; // Use the PORT environment variable if available, otherwise use port 3000
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});

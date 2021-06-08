const watchdog = require('./watchdog'); 
const cron = require('node-cron');

const lambdaSimulator = function() {
	let random = Math.floor(Math.random() * Math.floor(100));
	
	// The trapper key is : inf 
	if (random % 2 == 1){
	  watchdog.info("Random is unpair");
	  // Mongo db status unavailable: inf.mdb
	  watchdog.info(0, 'mdb');
	  // Service status unavailable
	  watchdog.info(0, 'svc');
	}else {
		
	  watchdog.info("Random is pair");
	  // Mongo db status available: inf.mdb
	  watchdog.info(1, 'mdb');
	  // Service status available: inf.svc
	  watchdog.info(1, 'svc');
	}	
}

// Schedule tasks to be run on the server.
cron.schedule('*/4 * * * * *', function() {
  watchdog.start();	
  lambdaSimulator();
  let random = Math.floor(Math.random() * Math.floor(100));
  watchdog.custom(random, 'cron.run.ok');
  random = Math.floor(Math.random() * Math.floor(100))
  watchdog.custom(random, 'cron.run.not_ok');
  // Send values
  watchdog.send();
  
});

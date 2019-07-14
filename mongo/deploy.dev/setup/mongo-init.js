db = db.getSiblingDB('admin');
db.createUser(
    {
        user: "mongoadmin",
        pwd: "mongoadmin",
        roles: [
            { role: "userAdminAnyDatabase", db: "admin" },
            { role: "read", db: "admin" }
        ]
    }
);

// Enable MongoDB's free cloud-based monitoring service, which will then receive and display
// metrics about your deployment (disk utilization, CPU, operation statistics, etc).

// The monitoring data will be available on a MongoDB website with a unique URL accessible to you
// and anyone you share the URL with. MongoDB may use this information to make product
// improvements and to suggest MongoDB products and deployment options to you.

// To enable free monitoring, run the following command: db.enableFreeMonitoring()
// To permanently disable this reminder, run the following command: db.disableFreeMonitoring()
db.disableFreeMonitoring()
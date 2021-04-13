rs.initiate({"_id" : "RS1", members : [{"_id" : 0, priority : 3, host : "mongo_1_1"},
        {"_id" : 1, host : "mongo_1_2"},
        {"_id" : 2, host : "mongo_1_3", arbiterOnly : true}]});
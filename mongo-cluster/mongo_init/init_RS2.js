rs.initiate({"_id" : "RS2", members : [{"_id" : 0, priority : 3, host : "mongo_2_1"},
        {"_id" : 1, host : "mongo_2_2"},
        {"_id" : 2, host : "mongo_2_3", arbiterOnly : true}]});
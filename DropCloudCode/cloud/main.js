
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
    response.success("Hello world!");
});



//After saving new post
//Check if the user exist in the users class
//if not, create user object and set the points value to 1

Parse.Cloud.afterSave("Posts", function(request) {

    var deviceId = request.object.get("deviceId");
    var location = request.object.get("location");
    var type = request.object.get("type");
    var postText = request.object.get('text');

    console.log(type);

    //Get the User object if it exist
    query = new Parse.Query("_User");
    query.equalTo("deviceId", deviceId);
    query.find({
        success: function(user) {

            var length = user.length;
            var userObject;

            if (length > 0)
            {
                userObject = user[0];
            }

            Parse.Cloud.useMasterKey();

            if (type == "New")
            {
                if (length == 0)
                {
                    //If the user does not exist
                    console.log("Creating A New User");
                    //Add a new user
                    newUser = new Parse.User();

                    newUser.set("username", deviceId);
                    newUser.set("password", deviceId);
                    newUser.set("deviceId", deviceId);
                    newUser.set("lastKnownLocation", location);
                    newUser.set("points", 1);

                    newUser.save();
                }else{
                    userObject.set("lastKnownLocation", location);
                    userObject.increment("points", 1);
                    userObject.save();
                }
            }else if (type == "Like" || type == "Dislike" || type == "Report"){
                if (length > 0)
                {
                    if (type == "Like")
                    {
                        userObject.increment("points", 2);
                        userObject.save();
                    }else if (type == "Dislike"){
                        userObject.increment("points", -2);
                        userObject.save();
                    }else if (type == "Report"){
                        userObject.increment("points", -5);
                        userObject.save();
                    }

                    //Create a notification object and save it
                    var Notification = Parse.Object.extend("Notifications");
                    var notification = new Notification();

                    var message = "";

                    if (type == "Like"){
                        message = "Someone liked your post: " + postText
                    }else if (type == "Dislike"){
                        message = "Someone disliked your post: " + postText
                    }else if (type == "Report"){
                        message = "Someone reported your post: " + postText
                    }

                    notification.set("message", postText);
                    notification.set("type", type);
                    notification.set("recipient",userObject.get("deviceId"));
                    notification.set("post", request.object);

                    notification.save(null, {
                        success: function(notification) {
                            // Execute any logic that should take place after the object is saved.
                            //send push notification
                            var authorDeviceId = userObject.get("deviceId");
                            var pushQuery = new Parse.Query(Parse.Installation);
                            pushQuery.equalTo('deviceId', authorDeviceId);

                            Parse.Push.send({
                                where: pushQuery, // Set our Installation query
                                data: {
                                    alert: message
                                }
                            }, {
                                success: function() {
                                    // Push was successful
                                    console.log("Pushed")
                                },
                                error: function(error) {
                                    throw "Got an error " + error.code + " : " + error.message;
                                }
                            });
                        },
                        error: function(notification, error) {
                            // Execute any logic that should take place if the save fails.
                            // error is a Parse.Error with an error code and message.
                            alert('Failed to create new object, with error code: ' + error.message);
                        }
                    });
                }
            }
        },
        error: function(error) {
            console.error("Got an error " + error.code + " : " + error.message);
        }
    });
});

Parse.Cloud.afterSave("Comments", function(request) {

    // Our "Comment" class has a "text" key with the body of the comment itself
    var commentText = request.object.get('text');
    var postId = request.object.get('postId');
    var type = request.object.get("type");

    console.log(type);

    var commenterDeviceId = request.object.get('deviceId');

    var Post = Parse.Object.extend("Posts");
    var query = new Parse.Query(Post);
    query.equalTo("objectId", postId);
    query.find({
        success: function(post) {
            // The object was retrieved successfully.

            if (post.length > 0)
            {
                postObject = post[0];

                var deviceId = postObject.get("deviceId");

                if (deviceId != commenterDeviceId)
                {
                    if (type != "Unlike")
                    {
                        //Create a notification object and save it
                        var Notification = Parse.Object.extend("Notifications");
                        var notification = new Notification();

                        var message = "Someone left a comment on your post: " + commentText;

                        if (type == "Like"){
                            message = "Someone liked your comment: " + commentText
                        }else if (type == "Dislike"){
                            message = "Someone disliked your comment: " + commentText
                        }else if (type == "Report"){
                            message = "Someone reported your comment: " + commentText
                        }

                        notification.set("message", commentText);
                        notification.set("type", type+"Comment");
                        notification.set("recipient",deviceId);
                        notification.set("post", postObject);
                        notification.set("comment", request.object);


                        notification.save(null, {
                            success: function(notification) {
                                // Execute any logic that should take place after the object is saved.
                                //send push notification
                                var pushQuery = new Parse.Query(Parse.Installation);
                                pushQuery.equalTo('deviceId', deviceId);

                                Parse.Push.send({
                                    where: pushQuery, // Set our Installation query
                                    data: {
                                        alert: message
                                    }
                                }, {
                                    success: function() {
                                        // Push was successful
                                        console.log("Pushed")
                                    },
                                    error: function(error) {
                                        throw "Got an error " + error.code + " : " + error.message;
                                    }
                                });
                            },
                            error: function(notification, error) {
                                // Execute any logic that should take place if the save fails.
                                // error is a Parse.Error with an error code and message.
                                alert('Failed to create new object, with error code: ' + error.message);
                            }
                        });
                    }
                }
            }
        },
        error: function(object, error) {
            // The object was not retrieved successfully.
            // error is a Parse.Error with an error code and message.
        }
    });
});


Parse.Cloud.afterSave("Invitations", function(request) {

    var receiverId = request.object.get('receiverId');
    var postId = request.object.get('postId');

    console.log("Receiver Id is "+receiverId);
    console.log("Post Id is "+postId);

    //get the post
    var Post = Parse.Object.extend("Posts");
    var query = new Parse.Query(Post);
    query.equalTo("objectId", postId);
    query.find({
        success: function(post) {
            // The object was retrieved successfully.

            if (post.length > 0)
            {
                postObject = post[0];

                var requestTo = postObject.get("deviceId");
                var message = "Someone requested a chat conversation with you: " + postObject.get('text');

                //send push notification
                var pushQuery = new Parse.Query(Parse.Installation);
                pushQuery.equalTo('deviceId', requestTo);

                Parse.Push.send({
                    where: pushQuery, // Set our Installation query
                    data: {
                        alert: message
                    }
                }, {
                    success: function() {
                        // Push was successful
                        console.log("Chat Request Sent!")
                        response.success("Chat Request Sent!");
                    },
                    error: function(error) {
                        throw "Got an error " + error.code + " : " + error.message;
                        console.log("Chat Request failed!")

                        response.error("Chat Request Failed! Please try again.");
                        //Delete the notification
                    }
                });
            }else{
                response.error("Chat Request Failed! Please try again.");
            }
        },
        error: function(object, error) {
            // The object was not retrieved successfully.
            // error is a Parse.Error with an error code and message.
            response.error("Chat Request Failed! Please try again.");
        }
    });




});






//request chat
Parse.Cloud.define("requestChat", function(request, response) {

    console.log(request)

    // Our "Comment" class has a "text" key with the body of the comment itself
    var requestBy = request.params.requestBy;
    var postId = request.params.postId;

    var Post = Parse.Object.extend("Posts");
    var query = new Parse.Query(Post);
    query.equalTo("objectId", postId);
    query.find({
        success: function(post) {
            // The object was retrieved successfully.

            if (post.length > 0)
            {
                postObject = post[0];

                var requestTo = postObject.get("deviceId");

                var Notification = Parse.Object.extend("Notifications");
                var query = new Parse.Query(Notification);
                query.equalTo("recipient", requestTo);
                query.equalTo("requestBy", requestBy);
                query.equalTo("postId", postId);
                query.find({
                    success: function (notifications) {
                        // The object was retrieved successfully.


                        if (notifications.length > 0) {
                            response.error("Multiple Chat Request Cannot Be Sent! Please wait for user's response.");
                        }else{
                            //Create a notification object and save it
                            var Notification = Parse.Object.extend("Notifications");
                            var notification = new Notification();

                            var message = "Someone requested a chat conversation with you: " + postObject.get('text');

                            notification.set("message", message);
                            notification.set("type", "ChatRequest");
                            notification.set("recipient",requestTo);
                            notification.set("requestBy",requestBy);
                            notification.set("post", postObject);
                            notification.set("postId", postId);


                            notification.save(null, {
                                success: function(notification) {
                                    // Execute any logic that should take place after the object is saved.
                                    //send push notification
                                    var pushQuery = new Parse.Query(Parse.Installation);
                                    pushQuery.equalTo('deviceId', requestTo);

                                    Parse.Push.send({
                                        where: pushQuery, // Set our Installation query
                                        data: {
                                            alert: message
                                        }
                                    }, {
                                        success: function() {
                                            // Push was successful
                                            console.log("Chat Request Sent!")
                                            response.success("Chat Request Sent!");
                                        },
                                        error: function(error) {
                                            throw "Got an error " + error.code + " : " + error.message;

                                            response.error("Chat Request Failed! Please try again.");
                                            //Delete the notification
                                        }
                                    });
                                },
                                error: function(notification, error) {
                                    // Execute any logic that should take place if the save fails.
                                    // error is a Parse.Error with an error code and message.
                                    alert('Failed to create new object, with error code: ' + error.message);
                                    response.error("Chat Request Failed! Please try again.");
                                }
                            });
                        }
                    },
                    error: function (object, error) {
                        // The object was not retrieved successfully.
                        // error is a Parse.Error with an error code and message.
                        response.error("Chat Request Failed! Please try again.");
                    }
                });


            }else{
                response.error("Chat Request Failed! Please try again.");
            }
        },
        error: function(object, error) {
            // The object was not retrieved successfully.
            // error is a Parse.Error with an error code and message.
            response.error("Chat Request Failed! Please try again.");
        }
    });

});

<?php

function display_delete_account_form() {
    echo '<!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Delete Account - ANDROCHECK</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                line-height: 1.6;
                margin: 0;
                padding: 0;
                background-color: #f4f4f4;
            }
            .container {
                max-width: 800px;
                margin: 50px auto;
                padding: 20px;
                background: #fff;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            }
            h1, h2 {
                color: #333;
            }
            p {
                color: #555;
            }
            form {
                margin-top: 20px;
            }
            label {
                display: block;
                margin-bottom: 10px;
                font-weight: bold;
            }
            input[type="text"], input[type="email"], input[type="password"] {
                width: 100%;
                padding: 10px;
                margin-bottom: 20px;
                border: 1px solid #ccc;
                border-radius: 4px;
            }
            input[type="submit"] {
                padding: 10px 20px;
                background-color: #d9534f;
                border: none;
                color: white;
                border-radius: 4px;
                cursor: pointer;
            }
            input[type="submit"]:hover {
                background-color: #c9302c;
            }
        </style>
        <script>
            function confirmDeletion(event) {
                event.preventDefault(); // Prevents form from submitting immediately
                if (confirm("Your account will be deleted in 24 hours. Do you wish to proceed?")) {
                    // If user confirms, submit the form
                    document.getElementById("deleteForm").submit();
                }
            }
        </script>
    </head>
    <body>
        <div class="container">
            <h1>Delete Account</h1>
            <p>If you wish to delete your account, please fill out the form below. This action cannot be undone.</p>
            <form id="deleteForm" action="delete_account.php" method="post" onsubmit="confirmDeletion(event)">
                <label for="username">Username:</label>
                <input type="text" id="username" name="username" required>
                
                <label for="email">Email:</label>
                <input type="email" id="email" name="email" required>
                
                <label for="password">Password:</label>
                <input type="password" id="password" name="password" required>
                
                <input type="submit" value="Delete Account">
            </form>
        </div>
    </body>
    </html>';
}

// Call the function to display the delete account form
display_delete_account_form();
?>
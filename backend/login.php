<?php
// Set headers for CORS and JSON response
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header("Content-Type: application/json");

// Include database connection
include 'db_connection.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Get POST data
    $email = isset($_POST['email']) ? $_POST['email'] : '';
    $password = isset($_POST['password']) ? $_POST['password'] : '';

    // Validate input
    if (empty($email) || empty($password)) {
        echo json_encode(['success' => false, 'message' => 'Email and password are required.']);
        exit();
    }

    // Prepare SQL statement to check if user exists
    $query = "SELECT doctorId, password FROM doctors WHERE email = ?";
    $stmt = $conn->prepare($query);

    if ($stmt === false) {
        echo json_encode(['success' => false, 'message' => 'Database query preparation failed.']);
        exit();
    }

    // Bind parameters and execute
    $stmt->bind_param("s", $email);
    $stmt->execute();
    
    // Bind result variables
    $stmt->bind_result($doctorId, $hashed_password);

    // Fetch results and verify password
    if ($stmt->fetch()) {
        if (password_verify($password, $hashed_password)) {
            echo json_encode(['success' => true, 'message' => 'Login successful.', 'doctorId' => strval($doctorId)]); // Convert to string
        } else {
            echo json_encode(['success' => false, 'message' => 'Invalid email or password.']);
        }
    } else {
        echo json_encode(['success' => false, 'message' => 'Invalid email or password.']);
    }

    $stmt->close();
    $conn->close();
}
?>

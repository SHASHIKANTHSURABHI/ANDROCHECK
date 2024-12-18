<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header("Content-Type: application/json");

// Database connection code here...
include 'db_connection.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Log incoming data for debugging
    error_log("Received data: " . print_r($_POST, true));
    error_log("Received file: " . print_r($_FILES, true));

    $doctorId = isset($_POST['doctorId']) ? intval($_POST['doctorId']) : null;  // Convert doctorId to integer
    $name = $_POST['name'] ?? null;
    $age = $_POST['age'] ?? null;
    $mobile = $_POST['mobile'] ?? null;

    // Validate that all fields are provided
    if (empty($doctorId) || empty($name) || empty($age) || empty($mobile)) {
        echo json_encode(['success' => false, 'message' => 'All fields are required.']);
        exit;
    }

    // Ensure age is a valid number (as integer)
    if (!is_numeric($age)) {
        echo json_encode(['success' => false, 'message' => 'Age must be a number.']);
        exit;
    }
    $age = (int) $age;  // Ensure age is an integer

    // Image upload handling
    if (isset($_FILES['image'])) {
        $target_dir = "uploads/";
        $target_file = $target_dir . basename($_FILES["image"]["name"]);
        $uploadOk = 1;

        // Check if the uploaded file is a valid image
        $check = getimagesize($_FILES["image"]["tmp_name"]);
        if ($check === false) {
            error_log("File is not a valid image.");
            echo json_encode(['success' => false, 'message' => 'File is not an image.']);
            $uploadOk = 0;
        }

        // Check file size (limit to 5MB)
        if ($_FILES["image"]["size"] > 5000000) {
            echo json_encode(['success' => false, 'message' => 'Sorry, your file is too large.']);
            $uploadOk = 0;
        }

        // Allow only certain file formats
        $imageFileType = strtolower(pathinfo($target_file, PATHINFO_EXTENSION));
        if (!in_array($imageFileType, ['jpg', 'png', 'jpeg', 'gif'])) {
            echo json_encode(['success' => false, 'message' => 'Sorry, only JPG, JPEG, PNG & GIF files are allowed.']);
            $uploadOk = 0;
        }

        // If $uploadOk is set to 0, return an error
        if ($uploadOk == 0) {
            echo json_encode(['success' => false, 'message' => 'Your file was not uploaded.']);
        } else {
            // Check if uploads directory exists
            if (!file_exists($target_dir)) {
                mkdir($target_dir, 0777, true);  // Create the directory if it doesn't exist
            }

            // Move the uploaded file
            if (move_uploaded_file($_FILES["image"]["tmp_name"], $target_file)) {
                $imagePath = $target_file;

                // Insert patient data into the database
                $stmt = $conn->prepare("INSERT INTO patients (doctorId, name, age, mobile, image_path) VALUES (?, ?, ?, ?, ?)");
                $stmt->bind_param("issss", $doctorId, $name, $age, $mobile, $imagePath);

                if ($stmt->execute()) {
                    $patientId = $conn->insert_id;  // Get the last inserted patientId
                    echo json_encode(['success' => true, 'patientId' => $patientId, 'image_path' => $imagePath]);
                } else {
                    echo json_encode(['success' => false, 'message' => 'Database error: ' . $stmt->error]);
                }
            } else {
                echo json_encode(['success' => false, 'message' => 'Sorry, there was an error uploading your file.']);
            }
        }
    } else {
        echo json_encode(['success' => false, 'message' => 'No image uploaded.']);
    }
}
?>

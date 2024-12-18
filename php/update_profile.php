<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header("Content-Type: application/json");
include 'db_connection.php'; // Ensure this is correct and working

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Capture POST data
    $doctorId = $_POST['doctorId'] ?? null;
    $firstName = $_POST['firstName'] ?? null;
    $lastName = $_POST['lastName'] ?? null;
    $phone = $_POST['phone'] ?? null; // Check 'phone' or 'phoneNumber'
    $dob = $_POST['dob'] ?? null;
    $gender = $_POST['gender'] ?? null;

    // Debug: Check if any required fields are missing
    error_log("Received Data: doctorId=$doctorId, firstName=$firstName, lastName=$lastName, phone=$phone, dob=$dob, gender=$gender");

    // Check required fields
    if (empty($doctorId) || empty($firstName) || empty($lastName) || empty($phone) || empty($dob) || empty($gender)) {
        echo json_encode(['success' => false, 'message' => 'All fields are required.']);
        exit;
    }

    // Initialize a variable to hold the new image path
    $newImagePath = null;

    // Fetch the current profile image path from the database
    $stmt = $conn->prepare("SELECT doctor_image_path FROM doctors WHERE doctorId = ?");
    $stmt->bind_param("i", $doctorId);
    $stmt->execute();
    $result = $stmt->get_result();

    $currentImagePath = null;
    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $currentImagePath = $row['doctor_image_path']; // Save the current image path
    }
    $stmt->close();

    // Image upload handling
    if (isset($_FILES['profileImage'])) {
        error_log("File Info: " . print_r($_FILES['profileImage'], true)); // Debug file data

        $target_dir = "uploads/";
        $target_file = $target_dir . basename($_FILES["profileImage"]["name"]);
        $uploadOk = 1;

        // Check if the image file is an actual image
        $check = getimagesize($_FILES["profileImage"]["tmp_name"]);
        if ($check === false) {
            echo json_encode(['success' => false, 'message' => 'File is not an image.']);
            $uploadOk = 0;
        }

        // Check file size (e.g., limit to 5MB)
        if ($_FILES["profileImage"]["size"] > 5000000) {
            echo json_encode(['success' => false, 'message' => 'Sorry, your file is too large.']);
            $uploadOk = 0;
        }

        // Allow certain file formats
        $imageFileType = strtolower(pathinfo($target_file, PATHINFO_EXTENSION));
        if (!in_array($imageFileType, ['jpg', 'jpeg', 'png', 'gif'])) {
            echo json_encode(['success' => false, 'message' => 'Sorry, only JPG, JPEG, PNG & GIF files are allowed.']);
            $uploadOk = 0;
        }

        // Check if $uploadOk is set to 0 by an error
        if ($uploadOk == 0) {
            echo json_encode(['success' => false, 'message' => 'Your file was not uploaded.']);
            exit; // Exit to prevent further processing
        } else {
            if (move_uploaded_file($_FILES["profileImage"]["tmp_name"], $target_file)) {
                $newImagePath = $target_file; // Set the new image path
                error_log("File uploaded successfully: $newImagePath"); // Debug successful upload

                // Delete the old image file if it exists
                if ($currentImagePath && file_exists($currentImagePath)) {
                    if (unlink($currentImagePath)) {
                        error_log("Old file deleted successfully: $currentImagePath");
                    } else {
                        error_log("Failed to delete old file: $currentImagePath");
                    }
                }
            } else {
                echo json_encode(['success' => false, 'message' => 'Sorry, there was an error uploading your file.']);
                exit; // Exit to prevent further processing
            }
        }
    }

    // Prepare the SQL update statement
    if ($newImagePath) {
        $stmt = $conn->prepare("UPDATE doctors SET firstName = ?, lastName = ?, phone = ?, dob = ?, gender = ?, doctor_image_path = ? WHERE doctorId = ?");
        $stmt->bind_param("ssssssi", $firstName, $lastName, $phone, $dob, $gender, $newImagePath, $doctorId);
    } else {
        $stmt = $conn->prepare("UPDATE doctors SET firstName = ?, lastName = ?, phone = ?, dob = ?, gender = ? WHERE doctorId = ?");
        $stmt->bind_param("sssssi", $firstName, $lastName, $phone, $dob, $gender, $doctorId);
    }

    // Execute the query
    if ($stmt->execute()) {
        echo json_encode(['success' => true, 'message' => 'Profile updated successfully!', 'data' => [
            'doctorId' => $doctorId,
            'firstName' => $firstName,
            'lastName' => $lastName,
            'phone' => $phone,
            'dob' => $dob,
            'gender' => $gender,
            'doctor_image_path' => $newImagePath ?? $currentImagePath
        ]]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Database error: ' . $stmt->error]);
    }

    // Close the statement and connection
    $stmt->close();
    $conn->close();
} else {
    echo json_encode(['success' => false, 'message' => 'Invalid request method.']);
}
?>

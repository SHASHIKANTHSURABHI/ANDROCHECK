-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Dec 10, 2024 at 09:09 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `doctor_database`
--

-- --------------------------------------------------------

--
-- Table structure for table `doctors`
--

CREATE TABLE `doctors` (
  `doctorId` int(11) NOT NULL,
  `email` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `firstName` varchar(50) NOT NULL,
  `lastName` varchar(50) NOT NULL,
  `phone` varchar(15) DEFAULT NULL,
  `dob` date DEFAULT NULL,
  `gender` enum('Male','Female','Other') DEFAULT NULL,
  `doctor_image_path` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `doctors`
--

INSERT INTO `doctors` (`doctorId`, `email`, `password`, `firstName`, `lastName`, `phone`, `dob`, `gender`, `doctor_image_path`) VALUES
(1, 'shashi@gmail.com', '$2y$10$5lcDxNXUK5Uw4Efy2FwN.OiI4gPw4ja2fCUu5BnSF3jcHfPUeYViK', 'shash', 'kanth', '1234567890', '2014-11-20', 'Male', 'uploads/1000107586.jpg'),
(9, 'shashik@gmail.com', '$2y$10$doa6gpAhsxiB6OtytGju2uc28ew23enhaNEZmgMYqchZfKWzX2x7W', 'surabhi', 'shashi', '63823738', '0000-00-00', 'Male', 'uploads/1000053713.jpg');

-- --------------------------------------------------------

--
-- Table structure for table `patients`
--

CREATE TABLE `patients` (
  `patientId` int(11) NOT NULL,
  `doctorId` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `age` int(11) NOT NULL,
  `mobile` varchar(15) NOT NULL,
  `image_path` varchar(255) DEFAULT NULL,
  `sperm_count` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `patients`
--

INSERT INTO `patients` (`patientId`, `doctorId`, `name`, `age`, `mobile`, `image_path`, `sperm_count`) VALUES
(125, 1, 'mavs', 35, '9542266652', 'uploads/1000149994.jpg', 30),
(127, 1, 'kumar', 56, '123456,107890', 'uploads/1000149985.png', 115),
(128, 1, 'valther', 41, '6527544876', 'uploads/1000149998.jpg', 9),
(148, 1, 'y', 6, '8', 'uploads/1000154263.jpg', 142),
(149, 9, 'hah', 6, '6', 'uploads/1000149998.jpg', 9);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `doctors`
--
ALTER TABLE `doctors`
  ADD PRIMARY KEY (`doctorId`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `patients`
--
ALTER TABLE `patients`
  ADD PRIMARY KEY (`patientId`),
  ADD UNIQUE KEY `patientId` (`patientId`),
  ADD KEY `doctorId` (`doctorId`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `doctors`
--
ALTER TABLE `doctors`
  MODIFY `doctorId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `patients`
--
ALTER TABLE `patients`
  MODIFY `patientId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=154;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `patients`
--
ALTER TABLE `patients`
  ADD CONSTRAINT `patients_ibfk_1` FOREIGN KEY (`doctorId`) REFERENCES `doctors` (`doctorId`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

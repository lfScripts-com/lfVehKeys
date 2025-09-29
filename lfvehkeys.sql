CREATE TABLE `vehicle_key` (
  `id` int(11) NOT NULL,
  `identifier` varchar(47) DEFAULT NULL,
  `label` varchar(255) DEFAULT NULL,
  `plate` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

ALTER TABLE `vehicle_key`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `vehicle_key`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
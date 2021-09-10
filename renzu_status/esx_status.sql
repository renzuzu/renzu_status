USE `es_extended`;

CREATE TABLE IF NOT EXISTS `status` (
    `status` LONGTEXT NULL DEFAULT '[]' COLLATE 'utf8mb4_general_ci',
    `identifier` VARCHAR(64) NULL DEFAULT '' COLLATE 'utf8mb4_general_ci',
    PRIMARY KEY (`identifier`) USING BTREE
)
COLLATE='utf8mb4_general_ci'
ENGINE=InnoDB
;
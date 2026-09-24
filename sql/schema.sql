-- ============================================================
-- 校园作品展示平台 - 数据库建表脚本
-- MySQL 8.0 / utf8mb4
-- 项目：基于SpringBoot的校园作品展示平台的设计与实现
-- 日期：2026-09-24
-- ============================================================

-- 删除数据库（开发环境使用，生产环境请注释掉）
DROP DATABASE IF EXISTS campus_work;

-- 创建数据库
CREATE DATABASE campus_work
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_general_ci;

-- 使用数据库
USE campus_work;

-- ============================================================
-- 1. 用户表 (user)
-- ============================================================
CREATE TABLE `user` (
    `id`          BIGINT       NOT NULL AUTO_INCREMENT       COMMENT '用户ID',
    `username`    VARCHAR(50)  NOT NULL                      COMMENT '用户名（登录账号）',
    `password`    VARCHAR(100) NOT NULL                      COMMENT '密码（BCrypt加密存储）',
    `nickname`    VARCHAR(50)  NOT NULL                      COMMENT '昵称（展示名）',
    `avatar`      VARCHAR(255) DEFAULT NULL                  COMMENT '头像URL',
    `email`       VARCHAR(100) DEFAULT NULL                  COMMENT '邮箱',
    `phone`       VARCHAR(20)  DEFAULT NULL                  COMMENT '手机号',
    `role`        TINYINT      NOT NULL DEFAULT 0            COMMENT '角色：0=学生，1=管理员',
    `status`      TINYINT      NOT NULL DEFAULT 1            COMMENT '状态：0=禁用，1=正常',
    `create_time` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表 - 存储学生与管理员账号信息';


-- ============================================================
-- 2. 分类表 (category)
-- ============================================================
CREATE TABLE `category` (
    `id`          BIGINT       NOT NULL AUTO_INCREMENT       COMMENT '分类ID',
    `name`        VARCHAR(50)  NOT NULL                      COMMENT '分类名称',
    `description` VARCHAR(200) DEFAULT NULL                  COMMENT '分类描述',
    `sort_order`  INT          NOT NULL DEFAULT 0            COMMENT '排序号（数值越小越靠前）',
    `create_time` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='分类表 - 作品分类管理（绘画/摄影/海报/程序/视频）';


-- ============================================================
-- 3. 作品表 (work)
-- ============================================================
CREATE TABLE `work` (
    `id`             BIGINT       NOT NULL AUTO_INCREMENT       COMMENT '作品ID',
    `user_id`        BIGINT       NOT NULL                      COMMENT '上传用户ID',
    `category_id`    BIGINT       NOT NULL                      COMMENT '所属分类ID',
    `title`          VARCHAR(100) NOT NULL                      COMMENT '作品标题',
    `description`    TEXT         DEFAULT NULL                  COMMENT '作品描述',
    `cover_url`      VARCHAR(255) NOT NULL                     COMMENT '封面图URL',
    `content_urls`   TEXT         NOT NULL                      COMMENT '作品内容URL列表（JSON数组字符串）',
    `work_type`      TINYINT      NOT NULL                      COMMENT '类型：0=图片，1=视频',
    `view_count`     INT          NOT NULL DEFAULT 0            COMMENT '浏览量',
    `like_count`     INT          NOT NULL DEFAULT 0            COMMENT '点赞数',
    `favorite_count` INT          NOT NULL DEFAULT 0            COMMENT '收藏数',
    `comment_count`  INT          NOT NULL DEFAULT 0            COMMENT '评论数',
    `status`         TINYINT      NOT NULL DEFAULT 0            COMMENT '状态：0=待审核，1=已通过，2=已驳回',
    `create_time`    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time`    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_category_id` (`category_id`),
    KEY `idx_status` (`status`),
    KEY `idx_create_time` (`create_time`),
    CONSTRAINT `fk_work_user`     FOREIGN KEY (`user_id`)     REFERENCES `user` (`id`),
    CONSTRAINT `fk_work_category` FOREIGN KEY (`category_id`) REFERENCES `category` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='作品表 - 作品主体信息与统计数据';


-- ============================================================
-- 4. 评论表 (comment)
-- ============================================================
CREATE TABLE `comment` (
    `id`          BIGINT       NOT NULL AUTO_INCREMENT       COMMENT '评论ID',
    `work_id`     BIGINT       NOT NULL                      COMMENT '所属作品ID',
    `user_id`     BIGINT       NOT NULL                      COMMENT '评论用户ID',
    `content`     VARCHAR(500) NOT NULL                      COMMENT '评论内容',
    `parent_id`   BIGINT       DEFAULT NULL                  COMMENT '父评论ID（NULL=顶级评论）',
    `create_time` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_work_id` (`work_id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_parent_id` (`parent_id`),
    CONSTRAINT `fk_comment_work`   FOREIGN KEY (`work_id`)   REFERENCES `work` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_comment_user`   FOREIGN KEY (`user_id`)   REFERENCES `user` (`id`),
    CONSTRAINT `fk_comment_parent` FOREIGN KEY (`parent_id`) REFERENCES `comment` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='评论表 - 作品评论与回复（自关联树形结构）';


-- ============================================================
-- 5. 点赞表 (work_like)
-- ============================================================
CREATE TABLE `work_like` (
    `id`          BIGINT   NOT NULL AUTO_INCREMENT       COMMENT '主键ID',
    `work_id`     BIGINT   NOT NULL                      COMMENT '作品ID',
    `user_id`     BIGINT   NOT NULL                      COMMENT '点赞用户ID',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_work_user` (`work_id`, `user_id`),
    KEY `idx_user_id` (`user_id`),
    CONSTRAINT `fk_like_work` FOREIGN KEY (`work_id`) REFERENCES `work` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_like_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='点赞表 - 用户对作品的点赞记录';


-- ============================================================
-- 6. 收藏表 (work_favorite)
-- ============================================================
CREATE TABLE `work_favorite` (
    `id`          BIGINT   NOT NULL AUTO_INCREMENT       COMMENT '主键ID',
    `work_id`     BIGINT   NOT NULL                      COMMENT '作品ID',
    `user_id`     BIGINT   NOT NULL                      COMMENT '收藏用户ID',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_fav_work_user` (`work_id`, `user_id`),
    KEY `idx_user_id` (`user_id`),
    CONSTRAINT `fk_fav_work` FOREIGN KEY (`work_id`) REFERENCES `work` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_fav_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='收藏表 - 用户对作品的收藏记录';


-- ============================================================
-- 7. 审核记录表 (audit_record)
-- ============================================================
CREATE TABLE `audit_record` (
    `id`           BIGINT       NOT NULL AUTO_INCREMENT       COMMENT '记录ID',
    `work_id`      BIGINT       NOT NULL                      COMMENT '被审核作品ID',
    `admin_id`     BIGINT       NOT NULL                      COMMENT '审核管理员ID',
    `audit_status` TINYINT      NOT NULL                      COMMENT '审核结果：1=通过，2=驳回',
    `reason`       VARCHAR(500) DEFAULT NULL                  COMMENT '驳回原因（通过时为空）',
    `create_time`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '审核时间',
    PRIMARY KEY (`id`),
    KEY `idx_work_id` (`work_id`),
    KEY `idx_admin_id` (`admin_id`),
    CONSTRAINT `fk_audit_work`  FOREIGN KEY (`work_id`)  REFERENCES `work` (`id`),
    CONSTRAINT `fk_audit_admin` FOREIGN KEY (`admin_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='审核记录表 - 管理员审核作品的操作记录';


-- ============================================================
-- 测试数据
-- ============================================================

-- ------------------------------------------------------------
-- 用户数据：1个管理员 + 5个学生
-- 注意：password 字段为 BCrypt 加密后的值
-- 明文密码：admin123 / student123
-- ------------------------------------------------------------
INSERT INTO `user` (`username`, `password`, `nickname`, `avatar`, `email`, `phone`, `role`, `status`) VALUES
('admin',     '$2a$10$N.ZMSn.5xn9pX8cR4mOQeOjV9F5xQ9j3qK7V2nF5r8o6Y1bE4c3W', '系统管理员', '/uploads/avatar/admin.png',     'admin@campus.edu.cn',    '13800000000', 1, 1),
('zhangsan',  '$2a$10$N.ZMSn.5xn9pX8cR4mOQeOjV9F5xQ9j3qK7V2nF5r8o6Y1bE4c3W', '张三',       '/uploads/avatar/zhangsan.png',  'zhangsan@campus.edu.cn', '13800000001', 0, 1),
('lisi',      '$2a$10$N.ZMSn.5xn9pX8cR4mOQeOjV9F5xQ9j3qK7V2nF5r8o6Y1bE4c3W', '李四',       '/uploads/avatar/lisi.png',      'lisi@campus.edu.cn',     '13800000002', 0, 1),
('wangwu',    '$2a$10$N.ZMSn.5xn9pX8cR4mOQeOjV9F5xQ9j3qK7V2nF5r8o6Y1bE4c3W', '王五',       '/uploads/avatar/wangwu.png',    'wangwu@campus.edu.cn',   '13800000003', 0, 1),
('zhaoliu',   '$2a$10$N.ZMSn.5xn9pX8cR4mOQeOjV9F5xQ9j3qK7V2nF5r8o6Y1bE4c3W', '赵六',       '/uploads/avatar/zhaoliu.png',   'zhaoliu@campus.edu.cn',  '13800000004', 0, 1),
('qianqi',    '$2a$10$N.ZMSn.5xn9pX8cR4mOQeOjV9F5xQ9j3qK7V2nF5r8o6Y1bE4c3W', '钱七',       '/uploads/avatar/qianqi.png',    'qianqi@campus.edu.cn',   '13800000005', 0, 0);

-- ------------------------------------------------------------
-- 分类数据：5个分类
-- ------------------------------------------------------------
INSERT INTO `category` (`name`, `description`, `sort_order`) VALUES
('绘画',   '手绘、板绘、油画、水彩等绘画类作品', 1),
('摄影',   '风景、人像、纪实等摄影类作品',     2),
('海报',   '活动海报、创意海报、公益海报等',   3),
('程序',   '项目截图、界面展示、代码作品等',   4),
('视频',   '短片、动画、Vlog等视频类作品',    5);

-- ------------------------------------------------------------
-- 作品数据：10个作品
-- content_urls 为 JSON 数组字符串，存储作品内容图片/视频的 URL
-- ------------------------------------------------------------
INSERT INTO `work` (`user_id`, `category_id`, `title`, `description`, `cover_url`, `content_urls`, `work_type`, `view_count`, `like_count`, `favorite_count`, `comment_count`, `status`) VALUES
(2, 1, '校园春景水彩画',       '用水彩记录校园春天的风景，樱花树下的教学楼。',                     '/uploads/cover/work01.jpg', '["/uploads/content/work01_1.jpg","/uploads/content/work01_2.jpg"]', 0,  156,  3, 2, 3, 1),
(3, 2, '图书馆日落摄影',       '黄昏时分图书馆的剪影，光影层次丰富。',                               '/uploads/cover/work02.jpg', '["/uploads/content/work02_1.jpg","/uploads/content/work02_2.jpg","/uploads/content/work02_3.jpg"]', 0, 289, 4, 2, 3, 1),
(2, 3, '校运会宣传海报',       '为校运会设计的创意宣传海报，运动主题配色。',                       '/uploads/cover/work03.jpg', '["/uploads/content/work03_1.jpg"]', 0,  98,  2, 1, 1, 1),
(4, 4, '在线选课系统界面展示', '校园在线选课系统的核心界面截图，含课程列表与选课流程。',           '/uploads/cover/work04.jpg', '["/uploads/content/work04_1.jpg","/uploads/content/work04_2.jpg"]', 0,  67,   2, 1, 0, 1),
(5, 1, '人物素描练习',         '课堂素描练习作品，人物光影结构练习。',                             '/uploads/cover/work05.jpg', '["/uploads/content/work05_1.jpg","/uploads/content/work05_2.jpg"]', 0,  45,   1, 0, 0, 1),
(3, 2, '校园猫咪图鉴',         '校园里几只常驻猫咪的摄影合集，记录它们的一天。',                   '/uploads/cover/work06.jpg', '["/uploads/content/work06_1.jpg","/uploads/content/work06_2.jpg","/uploads/content/work06_3.jpg","/uploads/content/work06_4.jpg"]', 0, 512, 3, 2, 4, 1),
(4, 5, '校园生活Vlog',         '记录一周校园生活的短视频，从早自习到社团活动。',                   '/uploads/cover/work07.jpg', '["/uploads/content/work07_1.mp4"]', 1, 423, 3, 2, 2, 1),
(2, 3, '读书月公益海报',       '为校园读书月活动设计的公益海报系列，共三张。',                     '/uploads/cover/work08.jpg', '["/uploads/content/work08_1.jpg","/uploads/content/work08_2.jpg","/uploads/content/work08_3.jpg"]', 0, 134, 2, 1, 0, 1),
(5, 4, '宿舍管理小程序截图',   '校园宿舍报修管理小程序的界面截图与功能流程展示。',                 '/uploads/cover/work09.jpg', '["/uploads/content/work09_1.jpg","/uploads/content/work09_2.jpg"]', 0,  15,   0, 0, 0, 0),
(6, 2, '毕业季人像摄影',       '毕业季同学的人像摄影作品，校园场景拍摄。',                         '/uploads/cover/work10.jpg', '["/uploads/content/work10_1.jpg","/uploads/content/work10_2.jpg"]', 0,  23,   2, 1, 0, 2);

-- ------------------------------------------------------------
-- 评论数据：顶级评论 + 回复
-- ------------------------------------------------------------
INSERT INTO `comment` (`work_id`, `user_id`, `content`, `parent_id`) VALUES
-- work_id=1 的评论
(1, 3, '色彩搭配很舒服，樱花的感觉出来了！', NULL),
(1, 4, '水彩的晕染效果很好看。',              NULL),
(1, 2, '谢谢大家的喜欢！',                     1),
-- work_id=2 的评论
(2, 5, '光影层次真的太棒了，求拍摄参数分享。', NULL),
(2, 3, '图书馆这个角度很有感觉。',             NULL),
(2, 4, '同感，黄昏的光线是最好拍的。',          5),
-- work_id=3 的评论
(3, 5, '海报配色很醒目，运动感十足。',          NULL),
-- work_id=6 的评论
(6, 2, '校园猫咪太可爱了！第三只表情绝了。',   NULL),
(6, 4, '图鉴形式很有创意，点赞。',             NULL),
(6, 5, '请问这些猫咪都在哪个校区呀？',         NULL),
(6, 3, '主要在南区宿舍楼附近。',               10),
-- work_id=7 的评论
(7, 2, '剪辑节奏很舒服，社团活动那段很燃。',   NULL),
(7, 5, '片头转场做得不错！',                   NULL);

-- ------------------------------------------------------------
-- 点赞数据
-- ------------------------------------------------------------
INSERT INTO `work_like` (`work_id`, `user_id`) VALUES
(1, 3), (1, 4), (1, 5),
(2, 2), (2, 4), (2, 5), (2, 6),
(3, 2), (3, 5),
(4, 3), (4, 5),
(5, 2),
(6, 2), (6, 3), (6, 4),
(7, 2), (7, 3), (7, 5),
(8, 3), (8, 4),
(10, 2), (10, 5);

-- ------------------------------------------------------------
-- 收藏数据
-- ------------------------------------------------------------
INSERT INTO `work_favorite` (`work_id`, `user_id`) VALUES
(1, 3), (1, 5),
(2, 2), (2, 5),
(3, 5),
(4, 3),
(6, 2), (6, 4),
(7, 2), (7, 5),
(8, 3),
(10, 2);

-- ------------------------------------------------------------
-- 审核记录数据
-- ------------------------------------------------------------
INSERT INTO `audit_record` (`work_id`, `admin_id`, `audit_status`, `reason`) VALUES
(1, 1, 1, NULL),
(2, 1, 1, NULL),
(3, 1, 1, NULL),
(4, 1, 1, NULL),
(5, 1, 1, NULL),
(6, 1, 1, NULL),
(7, 1, 1, NULL),
(8, 1, 1, NULL),
(10, 1, 2, '作品图片模糊，请上传更高清晰度的照片后重新提交。');

-- Suppression de la vue "score" dans le schéma "jolan.thomassin.1@ens.etsmtl.ca"
DROP VIEW IF EXISTS "jolan.thomassin.1@ens.etsmtl.ca"."score";

-- Création de la nouvelle vue "score" dans le schéma "jolan.thomassin.1@ens.etsmtl.ca"
CREATE VIEW "jolan.thomassin.1@ens.etsmtl.ca"."score" AS
SELECT ROUND((LENGTH(html_content) - min_length.min_val) * 1.0 / (max_length.max_val - min_length.min_val), 1) AS score
FROM louis_v004.crawl,
     (SELECT MIN(LENGTH(html_content)) AS min_val
      FROM louis_v004.crawl) AS min_length,
     (SELECT MAX(LENGTH(html_content)) AS max_val
      FROM louis_v004.crawl) AS max_length;




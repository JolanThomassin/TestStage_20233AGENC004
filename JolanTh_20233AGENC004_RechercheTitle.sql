-- Suppression de la fonction "recherche" existante
DROP FUNCTION IF EXISTS recherche(TEXT);

-- Création de la nouvelle fonction "recherche"
CREATE FUNCTION recherche(keyword TEXT) RETURNS TABLE (document_id UUID, score NUMERIC) AS $$
BEGIN
  RETURN QUERY
  SELECT s.id::UUID, CAST(s.score AS NUMERIC)
  FROM "jolan.thomassin.1@ens.etsmtl.ca".score AS s
  WHERE s.title ILIKE '%' || keyword || '%'
  ORDER BY s.score DESC
  LIMIT 10;
END;
$$ LANGUAGE plpgsql;

-- Recherche avec le mot-clé : "Canada"
SELECT * FROM recherche('Canada');
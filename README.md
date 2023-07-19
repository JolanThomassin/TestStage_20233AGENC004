# TestStage_20233AGENC004
Ce dépôt Git a été créé dans le cadre d'un test de stage en base de données. Il propose une série de tâches visant à évaluer les compétences d'un stagiaire dans la création de nouvelles tables, vues et fonctions au sein d'une base de données relationnelle accessible via Internet. Pour réaliser ce test j'ai utilisé l'outil DBeaver.

## Objectif :
Le dépôt vise à fournir un environnement de test pour un stagiaire en base de données, lui permettant de mettre en pratique ses connaissances et compétences dans la manipulation des bases de données relationnelles.

## Tâches :
Le dépôt comprend une liste de tâches à accomplir, chacune accompagnée d'une description détaillée des étapes à suivre. Les tâches incluent la création de nouvelles tables, vues et fonctions, ainsi que l'écriture de requêtes SQL spécifiques pour répondre à des problèmes donnés.

### Tâche 1 : Création du Git
e fichier README a été créé et mis à jour à la conclusion du projet. #1

### Tâche 2 : Création d'une vue "Score"
Après avoir établi la connexion à la base de données, j'ai créé une vue nommée "score" où j'ai copié les valeurs fournies et attribué à chaque valeur un score en fonction de sa longueur en caractères. Étant donné que l'énoncé ne précisait pas clairement s'il fallait inclure ou non les données de base dans la vue "score", j'ai pris deux approches distinctes : l'une consistant à créer une vue uniquement avec les scores, et l'autre incluant à la fois les scores et les données de base extraites du fichier. #2

### Tâche 3 : Fonction de recherche par mot-clé
En utilisant notre vue, j'ai mis en place une fonction de recherche qui récupère toutes les lignes contenant le mot-clé spécifié, puis sélectionne les 10 lignes ayant le score le plus élevé. #3

## Réponse aux questions
### Que contiennent les tables dans les schéma louis_v004? Expliquer la structure relationelle et la fonction dechaque table ?
En examinant les diagrammes de relations des tables, nous avons repéré la table ada_002 qui semble servir de stockage pour des tokens, identifiables par sa clé étrangère liée à la table Token. Cette table peut être utilisée pour effectuer des recherches ou des comparaisons entre les tokens, et disposer des embeddings de chaque token peut être bénéfique pour représenter les données de manière appropriée.

La table « Crawl » semble représenter des pages web. Chaque enregistrement dans cette table peut correspondre à une page web individuelle. Les pages web sont généralement collectées ou extraites à partir d'Internet à l'aide d'un processus appelé « crawling » (ou exploration de site web). Le terme « crawl » est couramment utilisé pour décrire cette action de collecte systématique de données à partir de multiples pages web. Ainsi, la table « Crawl » peut contenir des informations sur les pages web collectées, telles que l'URL, le contenu texte, le titre, etc.

La table « Chunk » est liée aux tables « Token » et « Crawl ». Un « chunk » signifie morceau, ou bloc, je peux donc en déduire que dans le contexte des pages web collectées, un « chunk » pourrait faire référence à une partie spécifique du contenu d'une page web. La table « Chunk » peut être utilisée pour diviser le contenu des pages web en unités plus petites et significatives, telles que des paragraphes, des sections ou des blocs de texte. Chaque enregistrement dans la table « Chunk » peut être associé à un « token » (un élément de texte) et à un « crawl » (une page web). Les informations supplémentaires telles que le titre peuvent fournir une précision supplémentaire sur le contenu du « chunk » dans le contexte de la page web correspondante.

En résumé, il semble que la table « Crawl » stocke des informations sur les pages web collectées, tandis que la table « Chunk » permet de diviser le contenu de ces pages en unités plus petites et d'associer ces « chunk » à des « tokens » et aux crawls correspondants. Cela pourrait servir à analyser, indexer ou organiser le contenu des pages web collectées.

### Quelle distribution prennent les valeurs de longueur du contenu ?
 - La plus petite valeur de longueur du contenu : 50 caractères
 - La plus grande valeur de longueur du contenu : 1 206 285 caractères
 - La longueur moyenne du contenu : 18015.62 caractère/moyen
 - La médiane de la longueur du contenu : 6833.0
```
SELECT MIN(LENGTH(html_content)) AS min_length,
       MAX(LENGTH(html_content)) AS max_length,
       AVG(LENGTH(html_content)) AS average_length,
       PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY LENGTH(html_content)) AS median_length
FROM louis_v004.crawl;
```
![image](https://github.com/JolanThomassin/TestStage_20233AGENC004/assets/98430140/a57feb59-8c63-41cb-94df-a122a3920b8d)

### Expliquer le calcul en fonction de la distribution spécifique des valeurs de longueurs de html_content script
Je vais utiliser les paramètres "min_length" et "max_length" pour attribuer un score en fonction des autres éléments présents. Pour ce faire, je compare la longueur de ma ligne de texte avec les longueurs minimale et maximale autorisées. Ensuite, j'arrondis la valeur obtenue pour qu'elle corresponde aux normes de l'énoncé, c'est-à-dire qu'elle soit comprise entre 0,0 et 0,1.
```
-- Création de la nouvelle vue "score" dans le schéma "jolan.thomassin"
CREATE VIEW "jolan.thomassin"."score" AS
SELECT crawl.*, ROUND((LENGTH(crawl.html_content) - min_length.min_val) * 1.0 / (max_length.max_val - min_length.min_val), 1) AS score
FROM louis_v004.crawl AS crawl,
     (SELECT MIN(LENGTH(html_content)) AS min_val
      FROM louis_v004.crawl) AS min_length,
     (SELECT MAX(LENGTH(html_content)) AS max_val
      FROM louis_v004.crawl) AS max_length;
```

### Expliquer et discuter de la performance de votre fonction recherche
Cette réponse ne prend pas en compte la création de la vue. La fonction de recherche effectue les étapes suivantes :
 - Recherche de tous les éléments contenant le mot-clé (Ordre n).
 - Tri des résultats par ordre décroissant à l'aide d'un algorithme de tri classique, généralement en ordre nlog(n).
 - Sélection des 10 premiers éléments (ordre asymptotique O(1)).
En considérant la partie la plus coûteuse, on peut conclure que l'algorithme a un ordre de complexité de O(n log(n)).
```
-- Création de la nouvelle fonction "recherche"
CREATE FUNCTION recherche(keyword TEXT) RETURNS TABLE (document_id UUID, score NUMERIC) AS $$
BEGIN
  RETURN QUERY
  SELECT s.id::UUID, CAST(s.score AS NUMERIC)
  FROM "jolan.thomassin.1@ens.etsmtl.ca".score AS s
  WHERE s.html_content ILIKE '%' || keyword || '%'
  ORDER BY s.score DESC
  LIMIT 10;
END;
$$ LANGUAGE plpgsql;
```

Il est envisageable d'optimiser un algorithme de recherche en appliquant différentes techniques telles que le tri préalable des données, l'élimination des boucles redondantes, ou l'utilisation d'algorithmes plus performants tels que le tri rapide ou le tri fusion.

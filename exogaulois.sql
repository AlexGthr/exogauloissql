-- 1. Nom des lieux qui finissent par 'um'. :

SELECT *    -- Je récupère tout les lieux avec *
FROM lieu      -- éléments qui se trouve dans le tableau lieu
WHERE nom_lieu LIKE '%um'   -- et je donne en condition seulement ceux qui finissent par um.

-- 2. Nombre de personnages par lieu (trié par nombre de personnages décroissant).

SELECT          -- Je récupère mes colonnes nom du lieu, et je calcul le nombre de personne
    lieu.nom_lieu, 
    COUNT(personnage.id_lieu) as nombre_personnes
FROM lieu          
INNER JOIN personnage ON lieu.id_lieu = personnage.id_lieu       -- J'y join la table personnage
GROUP BY lieu.nom_lieu  -- Je les regroupes par lieu pour éviter les doublons
ORDER BY nombre_personnes DESC  -- et je trie par nombre de personne dans l'ordre décroissant

-- 3. Nom des personnages + spécialité + adresse et lieu d'habitation, triés par lieu puis par nom de personnage.

SELECT          -- Je récupère mes nom de personnage, leurs spécialité, leurs adresse, et le lieu de la table lieu
	nom_personnage, 
	specialite.nom_specialite, 
	adresse_personnage, 
	lieu.nom_lieu
FROM personnage
INNER JOIN specialite ON personnage.id_specialite = specialite.id_specialite  -- j'y join la table specialité
INNER JOIN lieu ON personnage.id_lieu = lieu.id_lieu   -- Pareil pour la table lieu
ORDER BY lieu.nom_lieu          -- et je trie par nom de lieu
-- ORDER BY nom_personnage        Tri par nom du personnage

-- 4. Nom des spécialités avec nombre de personnages par spécialité (trié par nombre de personnages décroissant).

SELECT              -- je récupère mes nom de spécialité, et je calcul le nombre de personne par spécialité
    specialite.nom_specialite, 
    COUNT(personnage.id_specialite) as nombre_personnes     
FROM specialite
LEFT JOIN personnage ON specialite.id_specialite = personnage.id_specialite  -- j'y join ma table personne
GROUP BY specialite.nom_specialite  
ORDER BY nombre_personnes DESC

-- 5. Nom, date et lieu des batailles, classées de la plus récente à la plus ancienne (dates affichées au format jj/mm/aaaa).

SELECT 
    nom_bataille, 
    DATE_FORMAT(date_bataille, "%d/%m/%Y") AS dateDebataille, lieu.nom_lieu
FROM bataille
INNER JOIN lieu ON bataille.id_lieu = lieu.id_lieu
ORDER BY date_bataille DESC

-- 6. Nom des potions + coût de réalisation de la potion (trié par coût décroissant).

SELECT p.nom_potion, SUM(i.cout_ingredient*c.qte) AS cout_potion
FROM potion p
LEFT JOIN composer c
ON c.id_potion = p.id_potion
LEFT JOIN ingredient i
ON c.id_ingredient = i.id_ingredient
GROUP BY p.id_potion
ORDER BY cout_potion DESC

-- 7. Nom des ingrédients + coût + quantité de chaque ingrédient qui composent la potion 'Santé'.

SELECT 
	potion.nom_potion, 
	ingredient.nom_ingredient, 
	ingredient.cout_ingredient,
	composer.qte,
	ingredient.cout_ingredient * composer.qte AS coutTotal
FROM composer
INNER JOIN potion ON composer.id_potion = potion.id_potion
INNER JOIN ingredient ON composer.id_ingredient = ingredient.id_ingredient
WHERE potion.nom_potion = 'Santé'

-- 8. Nom du ou des personnages qui ont pris le plus de casques dans la bataille 'Bataille du village gaulois'.

SELECT
	personnage.nom_personnage,
	bataille.nom_bataille,
	sum(prendre_casque.qte) AS casquePris
FROM prendre_casque
INNER JOIN personnage ON prendre_casque.id_personnage = personnage.id_personnage
INNER JOIN bataille ON prendre_casque.id_bataille = bataille.id_bataille
WHERE bataille.nom_bataille = 'Bataille du village gaulois'
GROUP BY personnage.id_personnage
ORDER BY casquePris DESC

-- 9. Nom des personnages et leur quantité de potion bue (en les classant du plus grand buveur au plus petit).

SELECT
	personnage.nom_personnage,
	sum(boire.dose_boire) AS potionBu
FROM boire
INNER JOIN personnage ON boire.id_personnage = personnage.id_personnage
GROUP BY personnage.id_personnage
ORDER BY potionBu DESC 

-- 10. Nom de la bataille où le nombre de casques pris a été le plus important.

SELECT
	bataille.nom_bataille,
	sum(prendre_casque.qte) AS totalCasque
FROM prendre_casque
INNER JOIN bataille ON prendre_casque.id_bataille = bataille.id_bataille
GROUP BY bataille.nom_bataille
ORDER BY totalCasque DESC
LIMIT 1

-- 11. Combien existe-t-il de casques de chaque type et quel est leur coût total ? (classés par nombre décroissant)

SELECT 
	type_casque.nom_type_casque,
	count(casque.nom_casque),
	SUM(casque.cout_casque)
FROM type_casque
INNER JOIN casque ON type_casque.id_type_casque = casque.id_casque
GROUP BY type_casque.nom_type_casque

A REVOIR

-- 12. Nom des potions dont un des ingrédients est le poisson frais.

SELECT 
	potion.nom_potion
FROM composer
INNER JOIN potion ON composer.id_potion = potion.id_potion
INNER JOIN ingredient ON composer.id_ingredient = ingredient.id_ingredient
WHERE ingredient.nom_ingredient = 'Poisson frais'

-- 13. Nom du / des lieu(x) possédant le plus d'habitants, en dehors du village gaulois.

SELECT lieu.nom_lieu, COUNT(personnage.id_lieu) as nombre_personnes
FROM lieu
INNER JOIN personnage ON lieu.id_lieu = personnage.id_lieu
WHERE NOT lieu.nom_lieu = 'Village gaulois'
GROUP BY lieu.nom_lieu
ORDER BY nombre_personnes DESC

-- 14. Nom des personnages qui n'ont jamais bu aucune potion.

SELECT
	personnage.nom_personnage
FROM personnage
LEFT JOIN boire ON personnage.id_personnage = boire.id_personnage
WHERE boire.dose_boire IS NULL
GROUP BY personnage.id_personnage

-- 15. Nom du / des personnages qui n'ont pas le droit de boire de la potion 'Magique'.

SELECT
	personnage.nom_personnage
FROM personnage
LEFT JOIN autoriser_boire ON personnage.id_personnage = autoriser_boire.id_personnage
WHERE autoriser_boire.id_personnage IS NULL
GROUP BY personnage.id_personnage
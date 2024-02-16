-- 1. Nom des lieux qui finissent par 'um'. :

SELECT *
FROM lieu      
WHERE nom_lieu LIKE '%um'   

-- *********** --
-- Je récupère tout les lieux avec *
-- éléments qui se trouve dans le tableau lieu
-- et je donne en condition seulement ceux qui finissent par um.
-- *********** --


-- 2. Nombre de personnages par lieu (trié par nombre de personnages décroissant).

SELECT
    lieu.nom_lieu, 
    COUNT(personnage.id_lieu) as nombre_personnes
FROM lieu          
INNER JOIN personnage ON lieu.id_lieu = personnage.id_lieu
GROUP BY lieu.nom_lieu  
ORDER BY nombre_personnes DESC  

-- *********** --
-- Je récupère mes colonnes nom du lieu, et je calcul le nombre de personne
-- J'y join la table personnage
-- Je les regroupes par lieu pour éviter les doublons
-- et je trie par nombre de personne dans l'ordre décroissant
-- *********** --


-- 3. Nom des personnages + spécialité + adresse et lieu d'habitation, triés par lieu puis par nom de personnage.

SELECT
	nom_personnage, 
	specialite.nom_specialite, 
	adresse_personnage, 
	lieu.nom_lieu
FROM personnage
INNER JOIN specialite ON personnage.id_specialite = specialite.id_specialite
INNER JOIN lieu ON personnage.id_lieu = lieu.id_lieu   
ORDER BY lieu.nom_lieu
-- ORDER BY nom_personnage   Tri par nom du personnage

-- *********** --
-- Je récupère mes nom de personnage, leurs spécialité, leurs adresse, et le lieu de la table lieu
-- j'y join la table specialité
-- Pareil pour la table lieu
-- *********** --


-- 4. Nom des spécialités avec nombre de personnages par spécialité (trié par nombre de personnages décroissant).

SELECT              
    specialite.nom_specialite, 
    COUNT(personnage.id_specialite) as nombre_personnes     
FROM specialite
LEFT JOIN personnage ON specialite.id_specialite = personnage.id_specialite  
GROUP BY specialite.nom_specialite  
ORDER BY nombre_personnes DESC

-- *********** --
-- je récupère mes nom de spécialité, et je calcul le nombre de personne par spécialité
-- j'y join ma table personne
-- Je regroupe par nom de specialite
-- Et je classe par nombre de personne décroissant
-- *********** --


-- 5. Nom, date et lieu des batailles, classées de la plus récente à la plus ancienne (dates affichées au format jj/mm/aaaa).

SELECT 
    nom_bataille, 
    DATE_FORMAT(date_bataille, "%d/%m/%Y") AS dateDebataille,
	lieu.nom_lieu
FROM bataille
INNER JOIN lieu ON bataille.id_lieu = lieu.id_lieu
ORDER BY date_bataille DESC

-- *********** --
-- Je récupère mes nom de bataille, mes dates de bataille format jour/mois/année et le lieu
-- J'y join la table lieu
-- et je classe par date de bataille decroissant
-- *********** --


-- 6. Nom des potions + coût de réalisation de la potion (trié par coût décroissant).

SELECT p.nom_potion, SUM(i.cout_ingredient*c.qte) AS cout_potion
FROM potion p
LEFT JOIN composer c ON c.id_potion = p.id_potion
LEFT JOIN ingredient i ON c.id_ingredient = i.id_ingredient
GROUP BY p.id_potion
ORDER BY cout_potion DESC

-- *********** --
-- Je recupère le nom des potions et leurs couts
-- j'y inclus la table composer et ingredient
-- je regroupe par id potion
-- et je classe par cout décroissant
-- *********** --


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

___

SELECT 
	potion.nom_potion, 
	ingredient.nom_ingredient, 
	ingredient.cout_ingredient,
	composer.qte,
	ingredient.cout_ingredient * composer.qte AS coutTotal
FROM composer

INNER JOIN potion ON composer.id_potion = potion.id_potion
INNER JOIN ingredient ON composer.id_ingredient = ingredient.id_ingredient

WHERE potion.nom_potion IN 
(
	SELECT potion.nom_potion
	FROM potion
	WHERE potion.nom_potion = 'Santé'
)

-- *********** --
-- Je récupère le nom des potion, le nom des ingrédient, le cout, la qte, et le cout total
-- de ma table composer
-- Puis j'insère les tables potion/ingredient
-- Et j'insère une condition si la potion à le nom 'Santé'
-- *********** --


-- 8. Nom du ou des personnages qui ont pris le plus de casques dans la bataille 'Bataille du village gaulois'.

SELECT 
	p.nom_personnage, 
	SUM(pc.qte) AS nb_casques
FROM personnage p, bataille b, prendre_casque pc
WHERE p.id_personnage = pc.id_personnage
AND pc.id_bataille = b.id_bataille
AND b.nom_bataille = 'Bataille du village gaulois'

GROUP BY p.id_personnage

HAVING nb_casques >= ALL(

SELECT SUM(pc.qte)
 FROM prendre_casque pc, bataille b
 WHERE b.id_bataille = pc.id_bataille
 AND b.nom_bataille = 'Bataille du village gaulois'
 GROUP BY pc.id_personnage
)

-- *********** --
-- Je récupère le nom du personnage et le nombre de casque pris
-- de la table personnage, bataille et prendre casque
-- J'ajoute la condition si personnage et prendre casque on la même id de personnage,
-- ET que prendre casque à la même id bataille que la table bataille
-- ET que le nom de la bataille est 'Bataille du village gaulois'
-- je regroupe tout par id personnage.

-- Je rajoute une condition HAVING (qui permet d'utiliser des function sum() par exemple)
-- condition having qui récupère le plus grand nb de casque par rapport à tout de la bataille du village gaulois
-- *********** --


-- 9. Nom des personnages et leur quantité de potion bue (en les classant du plus grand buveur au plus petit).

SELECT
	personnage.nom_personnage,
	sum(boire.dose_boire) AS potionBu
FROM boire
INNER JOIN personnage ON boire.id_personnage = personnage.id_personnage
GROUP BY personnage.id_personnage
ORDER BY potionBu DESC 

-- *********** --
-- Je récupère le nom du personnage et le nombre de potion bu
-- De la table boire
-- Je join la table boire, et je regroupe par id personnage
-- Et j'affiche dans l'ordre de potionBu décroissant
-- *********** --


-- 10. Nom de la bataille où le nombre de casques pris a été le plus important.

SELECT 
	b.nom_bataille,
	SUM(pc.qte) AS totalCasque
FROM bataille b, prendre_casque pc
WHERE b.id_bataille = pc.id_bataille

GROUP BY b.nom_bataille

HAVING totalCasque >= ALL(
	SELECT 
		SUM(pc.qte) AS totalCasque
	FROM bataille b, prendre_casque pc
	WHERE b.id_bataille = pc.id_bataille

	GROUP BY b.nom_bataille
)

-- *********** --
-- * commentaire 8.
-- *********** --


-- 11. Combien existe-t-il de casques de chaque type et quel est leur coût total ? (classés par nombre décroissant)

SELECT 
	type_casque.nom_type_casque,
	count(casque.id_casque) AS nombreCasque,
	SUM(casque.cout_casque) AS coutTotal
FROM type_casque
INNER JOIN casque ON type_casque.id_type_casque = casque.id_type_casque
GROUP BY type_casque.nom_type_casque

-- *********** --
-- Je récupère le nom des types de casque, le total de casque, et leurs couts total
-- Je join la table casque et je regroupe le tout.
-- *********** --


-- 12. Nom des potions dont un des ingrédients est le poisson frais.

SELECT 
	potion.nom_potion
FROM composer
INNER JOIN potion ON composer.id_potion = potion.id_potion
INNER JOIN ingredient ON composer.id_ingredient = ingredient.id_ingredient
WHERE ingredient.nom_ingredient = 'Poisson frais'

-- *********** --
-- Je récupère le nom de la potion de la table potion
-- Je traite le tout dans la table composer ou j'ai join les tables potion et ingredient
-- et je demande uniquement celle qui ont comme ingrédient, le 'Poisson frais'
-- *********** --


-- 13. Nom du / des lieu(x) possédant le plus d'habitants, en dehors du village gaulois.

SELECT lieu.nom_lieu, COUNT(personnage.id_personnage) as nombre_personnes
FROM lieu, personnage
WHERE lieu.id_lieu = personnage.id_lieu
GROUP BY lieu.nom_lieu

HAVING lieu.nom_lieu IN 
( 
	SELECT nom_lieu
	FROM lieu
	WHERE NOT lieu.nom_lieu = 'Village gaulois'
)
ORDER BY nombre_personnes DESC

-- *********** --
-- Je récupère mon nom du lieu, je compte l'id des personnages
-- de la table lieu et personnage
-- uniquement les lieux et personnage ayant la même id lieu
-- je regroupe par nom lieu

-- et je rajoute un HAVING pour recupérer uniquement les villages hors Village gaulois (where NOT)
-- *********** --


-- 14. Nom des personnages qui n'ont jamais bu aucune potion.

SELECT personnage.nom_personnage
FROM personnage
WHERE NOT personnage.id_personnage IN  
(
	SELECT boire.id_personnage
	FROM boire
)

-- *********** --
-- Je récupère mes nom de personnage,
-- et j'ajoute une condition si il ne sont pas dans la table boire. 
-- (22 personnages / 42)
-- *********** --


-- 15. Nom du / des personnages qui n'ont pas le droit de boire de la potion 'Magique'.

SELECT personnage.nom_personnage
FROM personnage
WHERE NOT personnage.id_personnage IN  
(
	SELECT autoriser_boire.id_personnage
	FROM autoriser_boire
)

-- *********** --
-- Je récupère mes nom de personnage,
-- et j'ajoute une condition si il ne sont pas dans la table autoriser boire. 
-- (18 personnages / 42)
-- *********** --


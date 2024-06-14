# Perception de la taskboard avec SIFT

<section id="localisation-de-la-task-board-a-l-aide-de-sift">
<style>
    .image{
    border: 5px solid #116aa4;
    border-radius: 10px;
    /* padding: 2px; */
    }
</style>

## Ressources
<ul class="simple">
<li><p><a class="reference external" href="https://github.com/platonics-delft/franka_learning_from_demonstrations">https://github.com/platonics-delft/franka_learning_from_demonstrations</a></p></li>
<li><p><a class="reference external" href="https://www.vlfeat.org/api/sift.html">https://www.vlfeat.org/api/sift.html</a></p></li>
</ul>

## A propos de “SIFT”
<div class="sift" align="justify">
<p>SIFT (Scale-invariant feature transform) est un algorithme de perception assistée par ordinateur permettant de détecter des zones d’intérêts dans une image, c’est-à-dire de faire une correspondance entre deux images ou deux flux, à partir des points qui peuvent être similaires entre les deux.
<br>Cet algorithme a été publié par David Lowe en 1999, et le propriétaire du brevet est l’Université de la Colombie-Britannique (en anglais, University of British Columbia, UBC).
<br>Cet algorithme inclut la reconnaissance d’objets et de mouvements (d’où son utilisation dans notre cas car on détecte la task-board en temps réel pendant l’exécution d’une tâche), de la modélisation 3D, mais aussi du suivi vidéo. Ici, on l’utilise donc la gestion des déplacements et de la planification des trajectoires du Panda Franka Emika par visualisation à l’aide de notre caméra de profondeur.
<br>Cet algorithme consiste à rechercher des points caractéristiques (appelés « features ») sur une image (qu'on appellera l'image de référence) qui seront décrits chacun par des coordonnées (selon les deux axes dans le plan x et y), une orientation, une échelle, ainsi que 128 descripteurs (en fonction de la version de l’algorithme).
<br>En résumé, l’idée générale de SIFT est donc de trouver des points-clés qui sont invariants à plusieurs transformations : rotation, échelle, illumination et changements mineurs du point de vue.</p>
</div>

<table align="center" width= "70%">
  <tr>
    <th>
      <div class="image">
        <img src="./img/new/Keypoint.png"/>
      </div>
    </th>
  </tr>
</table>

```{mermaid}
---
caption: Exemple de détection des points clés d'une image sous différents paramètres.
align: 'center'
---
graph LR

```

## Qu’est-ce qu’un descripteur SIFT ?
<div class="sift" align="justify">
<p>Un descripteur SIFT est défini comme un histogramme spatial 3D des gradients de l’image caractérisant l’apparence d’un “<em>point clé</em>”. Le gradient de chaque pixel est considéré comme un échantillon d’un vecteur de caractéristique élémentaire tridimensionnel, formé par la position du pixel (selon x et y) et l’orientation du gradient. Les échantillons sont pondérés par la norme du gradient et accumulés dans un histogramme 3D appelé “<em>h</em>”, qui (après normalisation et étalonnage) forme le descripteur SIFT de la région. Une fonction de pondération gaussienne supplémentaire est appliquée pour donner moins d’importance aux gradients plus éloignés du centre du point clé.</p>
</div>
<table align="center">
  <tr>
    <th>
      <div class="image">
        <img src="./img/new/SIFT_descriptor.png"/>
      </div>
    </th>
  </tr>
</table>

```{mermaid}
---
caption: L'histogramme spatial 3D du gradient de l'image représente le SIFT descripteur
align: 'center'
---
graph LR

```

## Les différentes étapes de l’algorithme SIFT
<div class="blue_button" align="justify">
<li><p><h3>Détection des points clés (<code class="docutils literal notranslate"><span class="pre">Keypoint</span> <span class="pre">Detection</span></code>) :</h3></p>

<ul class="simple">
<li><p><h4>Espace d’échelle :</h4> SIFT construit un espace d’échelle en générant une série d’images floutées en appliquant des “<em>filtres gaussiens</em>” de différentes échelles (en variant “<em>sigma</em>”). Cela permettra de capturer les caractéristiques à différentes résolutions.</p></li>
<li><p><h4>Différences de Gaussiennes (<code class="docutils literal notranslate"><span class="pre">DoG</span></code>) :</h4> Des images de différences de Gaussiennes sont générées en soustrayant des images floutées adjacentes. Les extrema (maximum et minimum) locaux dans ces images DoG sont identifiés comme des points d’intérêt potentiels.</p></li>

<table align="center">
  <tr>
    <th>
      <div class="image">
        <img src="./img/new/Diff_Gauss.png"/>
      </div>
    </th>
  </tr>
</table>

```{mermaid}
---
caption: Différences de Gaussiens.
align: 'center'
---
graph LR

```

<li><p><h4>Recherche d’<code class="docutils literal notranslate"><span class="pre">extrema</span></code> :</h4> Pour chaque point dans l’image DoG, on compare ses valeurs avec ses voisins dans les niveaux d’échelle adjacents et les voisins spaciaux. Si le point est un extremum local, il est sélectionné comme un point d’intérêt candidat.</p></li>

<table align="center">
  <tr>
    <th>
      <div class="image">
        <img src="./img/new/DoG_SIFT.png"/>
      </div>
    </th>
  </tr>
</table>

```{mermaid}
---
caption: Exemple de détection d'extremum dans l'espace des échelles.
align: 'center'
---
graph LR

```

</ul>
<table align="center">
  <tr>
    <th>
      <div class="image">
        <img src="./img/new/DoG_scale.png"/>
      </div>
    </th>
  </tr>
</table>

```{mermaid}
---
caption: Construction de l'espace d'échelle(GSS : Gaussian Scale Space) et des différences de Gaussiennes (DoG)
align: 'center'
---
graph LR

```

Cette image illustre le processus de création de l'espace d'échelle (Gaussian Scale Space, GSS) et des différences de Gaussiennes (Differences of Gaussians, DoG) pour détecter les points d'intérêt dans l'algorithme SIFT.
<ul class="simple">
<li><p><h6>Axes des échelles et des octaves :</h6> L’axe horizontal supérieur représente les échelles σ (écart-types des filtres gaussiens), tandis que l’axe inférieur représente les octaves (résolutions successives de l’image).</p></li>
<li><p><h6>Espaces d’échelle gaussiens (GSS) :</h6> Les courbes noires montrent les niveaux d’échelle −1 à 44 pour chaque octave, obtenus par convolution de l’image d’entrée avec des filtres gaussiens croissants.</p></li>
<li><p><h6>Differences of Gaussians (DoG) :</h6> Les courbes violettes indiquent les images DoG, obtenues en soustrayant des images GSS successives.</p></li>
<li><p><h6>Calcul des extrema DoG :</h6> Les étoiles vertes marquent les positions où les extrema (maxima et minima locaux) sont détectés dans les images DoG, identifiant les points clés potentiels.</p></li>
<li><p><h6>Paramètres :</h6> L’image précise les indices d’échelle smin​=−1 et smax​=S+2, avec S=3 niveaux d’échelle par octave et O=3 octaves.</p></li>
</ul>
<p>Cette représentation graphique aide à comprendre comment les points d’intérêt robustes et invariants sont extraits de différentes échelles dans l’algorithme SIFT.
<br></p>
</li>

<table align="center">
  <tr>
  <th>
  <div class="image">
  <img src="./img/new/Sift_keypoints_filtering.jpg"/>
  </div>
  </th>
  </tr>
</table>

```{mermaid}
---
caption: Un autre exemple de détection d'extremum
align: 'center'
---
graph LR

```

<li><p><h3>Affinement des points clés (<code class="docutils literal notranslate"><span class="pre">Keypoint</span> <span class="pre">Refinement</span></code>) :</h3></p>
<ul class="simple">
<li><p><h4>Rejet des points instables :</h4> Les points clés candidats sont affinés pour rejeter les points instables. Ceux dont les réponses sont très faibles (faible contraste) ou qui sont trop proches des bords (instabilité aux bords) sont éliminés.</p></li>
<li><p><h4>Interpolation :</h4> Une interpolation quadratique est utilisée pour localiser précisément la position du point clé en espace d’échelle.</p></li>
</ul>
</li>
<li><p><h3>Assignation d’orientation (<code class="docutils literal notranslate"><span class="pre">Orientation</span> <span class="pre">Assignment</span></code>) :</h3></p>
<ul class="simple">
<li><p><h4>Histogramme d’orientations :</h4> Pour chaque point clé, un histogramme des orientations des gradients est construit dans une région locale autour du point clé. Les orientations des gradients sont pondérées par la magnitude du gradient et une fonction gaussienne centrée sur le point clé.</p></li>
<li><p><h4>Orientation principale :</h4> Le pic de l’histogramme d’orientations est attribué comme l’orientation principale du point clé. Des orientations supplémentaires peuvent être assignées si des pics secondaires significatifs sont présents, ce qui rend le descripteur invariant à la rotation.</p></li>
</ul>
<table align="center">
  <tr>
    <th>
      <div class="image">
        <img src="./img/new/Orientation_assignment.png"/>
      </div>
    </th>
  </tr>
</table>

```{mermaid}
---
caption: Assignation d'orientation dans l'algorithme SIFT
align: 'center'
---
graph LR

```

<p>Cette image illustre le processus d’assignation d’orientation à un point clé dans l’algorithme SIFT.</p>
<ul class="simple">
<li><p><h6>Région de sondage (Polling region) :</h6> L’image de gauche montre la région de sondage autour d’un point clé. Cette région est utilisée pour collecter les informations de gradient nécessaires pour assigner une orientation au point clé. La région est centrée sur le point clé et son rayon est proportionnel à l’échelle du point clé (σ).</p></li>
<li><p><h6>Échelle du point clé (Keypoint scale σ) :</h6> La ligne violette représente l’échelle du point clé, indiquant la taille de la région de sondage utilisée pour l’analyse des gradients.</p></li>
<li><p><h6>Histogramme des orientations :</h6> L’image de droite montre un histogramme des orientations des gradients dans la région de sondage. L’axe horizontal représente les angles d’orientation allant de 0 à 2π, tandis que l’axe vertical représente la magnitude des gradients.</p></li>
<li><p><h6>Détermination de l’orientation principale :</h6> Le pic le plus élevé de l’histogramme (max) est considéré comme l’orientation principale du point clé. Les orientations sont quantifiées en 36 bins (intervalles) autour du cercle 0 à 2π.</p></li>
<li><p><h6>Seuil secondaire :</h6> Une orientation supplémentaire peut être assignée si une autre valeur de l’histogramme est au moins 80% de la valeur maximale, comme illustré par la ligne pointillée horizontale. Cela permet au point clé d’avoir plusieurs orientations, augmentant la robustesse aux variations de rotation.</p></li>
</ul>
<p>Cette assignation d’orientation permet aux descripteurs SIFT d’être invariants à la rotation, ce qui est essentiel pour une correspondance robuste entre des images prises sous différents angles.
<br></p>
</li>
<li><p><h3>Construction du descripteur de point clé (<code class="docutils literal notranslate"><span class="pre">Keypoint</span> <span class="pre">Descriptor</span></code>) :</h3></p>
<ul class="simple">
<li><p><h4>Région locale :</h4> Une région locale autour de chaque point clé est considérée (généralement une grille de 16x16 pixels).</p></li>
<li><p><h4>Histogrammes de gradients locaux :</h4> Cette région est divisée en sous-régions de 4x4, et pour chacune, un histogramme de l'orientation des gradients est construit (8 orientations).</p></li>
<li><p><h4>Vecteur descripteur :</h4> Les histogrammes sont concaténés pour former un vecteur de 128 dimensions (16 sous-régions x 8 orientations). Ce vecteur est normalisé pour améliorer la robustesse aux changements d’illumination et de contraste.</p></li>
</ul>
</li>
<li><p><h3>Correspondance des descripteurs (<code class="docutils literal notranslate"><span class="pre">Descriptor</span> <span class="pre">Matching</span></code>) :</h3></p>
<ul class="simple">
<li><p><h4>Recherche de voisins proches :</h4> Les descripteurs de l’image modèle et de l’image d’entrée sont comparés pour trouver des correspondances. La méthode de correspondance utilise typiquement la recherche de plus proches voisins.</p></li>
<li><p><h4>Ratio de Lowe :</h4> Pour filtrer les correspondances incorrectes, le ration de Lowe est appliqué. Il compare le meilleur match avec le second meilleur match et accepte le match seulement si le rapport de leurs distances est inférieur à un seuil (typiquement 0.7).</p></li>
</ul>
<table align="center">
  <tr>
    <th>
      <div class="image">
        <img src="./img/new/Lowe_SIFT.png"/>
      </div>
    </th>
  </tr>
</table>

```{mermaid}
---
caption: Conventions de coordonnées et d'orientation et histogrammes des gradients spatiaux
align: 'center'
---
graph LR

```

</li>
<li><p><h3>Calcul de la trasformation (<code class="docutils literal notranslate"><span class="pre">Transformation</span> <span class="pre">Calculation</span></code>) :</h3></p>
<ul class="simple">
<li><p><h4>Homographie :</h4> Les correspondances de points clés sont utilisées pour estimer une transformation géométrique (homographie) entre l’image modèle et l’image d’entrée (celle de la caméra). Cela est généralement fait en utilisant l’algorithme RANSAC pour être robuste aux correspondances erronées.</p></li>
<li><p><h4>Alignement :</h4> L’homographie permet d’aligner l’image template avec l’image capturée, localisant ainsi l’objet dans la nouvelle image.</p></li>
</ul>
</li>
</div>
</ul>

## Méthodes utilisées
<table align="center">
  <tr>
    <th>
      <div class="image">
        <img src="./img/new/SIFT.png"/>
      </div>
    </th>
  </tr>
</table>

```{mermaid}
---
caption: Aperçu de la localisation par SIFT avec la correspondance des points entre l'image de la boîte et le flux de vidéo capturé par la caméra
align: 'center'
---
graph LR

```

<p>Deux scripts python (<em>localizer_sift.py</em> et <em>localizer_service</em>) principales, permettent ici de réaliser la localisation de la task-board à l’aide d’une caméra :</p>

<div class="highlight-bash notranslate"><div class="highlight"><pre><span></span>class<span class="w"> </span>Localizer<span class="o">(</span>self<span class="o">)</span>
<span class="o">{</span>
<span class="w">   </span>func<span class="w"> </span>__init__<span class="o">(</span>self,<span class="w"> </span>template,<span class="w"> </span>cropping,<span class="w"> </span>depth<span class="o">)</span>
<span class="w">   </span><span class="c1"># Fonction permettant de traiter les messages `CameraInfo` reçus de ROS</span>
<span class="w">   </span>func<span class="w"> </span>camera_info_callback<span class="o">(</span>self,<span class="w"> </span>msg<span class="o">)</span>
<span class="w">   </span>func<span class="w"> </span>set_image<span class="o">(</span>self,<span class="w"> </span>img<span class="o">)</span>
<span class="w">   </span>func<span class="w"> </span>detect_points<span class="o">(</span>self<span class="o">)</span>
<span class="w">   </span>func<span class="w"> </span>annoted_image<span class="o">(</span>self<span class="o">)</span>
<span class="w">   </span>func<span class="w"> </span>compute_tf<span class="o">(</span>self<span class="o">)</span>
<span class="w">   </span>func<span class="w"> </span>compute_full_tf_in_m<span class="o">(</span>self<span class="o">)</span>
<span class="o">}</span>
func<span class="w"> </span>compute_transform<span class="o">(</span>points:<span class="w"> </span>np.ndarray,<span class="w"> </span>transformed_points:<span class="w"> </span>np.ndarray<span class="o">)</span>
</pre></div>
</div>

<ul class="simple">
<div class="blue_button" align="justify">
<li><p><h4>Le 1er script "<i>localizer_sift.py</i>" :</h4> Ce script crée une classe “<code class="docutils literal notranslate"><span class="pre"><em>localizer</em></span></code>” qui permet de localiser des points clés dans une image (celle capturée par la caméra) en utilisant un modèle de référence (image template de la task-board à une position donnée) :</p>
<ul>
<li><p><h6>La classe contient 3 attributs principaux :</h6></p>
<ul>
<li><p><code class="docutils literal notranslate"><span class="pre">template</span></code> permettant de récupérer le chemin de l’image template de la task-board,</p></li>
<li><p><code class="docutils literal notranslate"><span class="pre">cropping</span></code>, un tuple contenant les coordonnées pour recadrer l’image modèle,</p></li>
<li><p><code class="docutils literal notranslate"><span class="pre">depth</span></code>, la profondeur de la task-board en mètre.</p></li>
</ul>
</li>
<li><p><h6>Les étapes principales sont :</h6></p>
<ul>
<li><p>Chargement de l’image modèle en niveaux de gris,</p></li>
<li><p>Recadrage de l’image modèle selon les coordonnées fournies,</p></li>
<li><p>Initialisation de la transformation de translation en fonction du recadrage de la caméra par rapport à la task-board,</p></li>
<li><p>Obtention des informations de la caméra à partir d’un Subscriber sur le topic ROS <code class="docutils literal notranslate"><span class="pre">/camera/color/camera_info,</span></code></p></li>
<li><p>Initialisation des facteurs de conversions pour les pixels en unités SI c’est en mètre pour la position et en radian pour l’orientation.</p></li>
</ul>
</li>
<li><p><h6>Description des méthodes principales utilisées :</h6></p>
<ul>
<li><p><code class="docutils literal notranslate"><span class="pre">set_image(self,</span> <span class="pre">img)</span></code> permet de définir l’image sur laquelle la localisation sera effectuée, donc l’image capturée par la caméra,</p></li>
<li><p><code class="docutils literal notranslate"><span class="pre">detect_points(self)</span></code> permet de détecter les points d’intérêts dans l’image d’entrée en utilisant le principe de SIFT,</p></li>
<li><p><code class="docutils literal notranslate"><span class="pre">annoted_image(self)</span></code> va retourner l’image annotée avec les correspondances trouvées,</p></li>
<li><p><code class="docutils literal notranslate"><span class="pre">compute_tf(self)</span></code> va calculer la transformation affine entre les points clés détectés pour ensuite retourner une matrice carrée de dimension 3,</p></li>
<li><p><code class="docutils literal notranslate"><span class="pre">compute_full_tf_in_m(self)</span></code> va calculer la transformation complète en unités SI pour ensuite retourner une matrice carrée de dimension 4.</p></li>
</ul>
</li>
<li><p><h6>Fonction hors classe <code class="docutils literal notranslate"><span class="pre">compute_transform(points:</span> <span class="pre">np.ndarray,</span> <span class="pre">transformed_points:</span> <span class="pre">np.ndarray)</span></code> :</h6> Elle permet de calculer la transformation affine partielle entre deux ensemble de points en prenant en argument des points originaux et des points transformés pour au final renvoyer une matrice de transformation carrée de dimension 3.</p></li>
</ul>
</li>
</div>
</ul>

```bash
class LocalizationService(){
    func __init__(self)
    func compute_localization_in_pixels(self, img: Image)
    func publish_annoted_image(self)
    func handle_request(self, req)
    func run(self)
}
```

<ul class="simple">
<div class="blue_button" align="justify">
<li><p><h4>Le 2nd script "<i>localizer_service</i>" :</h4> Ce script crée une classe “<code class="docutils literal notranslate"><span class="pre"><em>LocalizationService</em></span></code>” qui met en place un service ROS pour la localisation d'objets en utilisant l'algorithme SIFT (tout ce script permet de transformer toute la localisation avec SIFT en un service ROS qui facilite le traitement et le rend plus fluide en utilisant les différents aspects de ROS qui permettent de rendre la perception plus facile):</p>
<ul>
<li><p><h6>La classe contient 3 méthodes principales :</h6></p>
<ul>
<li><p><code class="docutils literal notranslate"><span class="pre">compute_localization_in_pixels(self, img: Image)</span></code> : permet de calculer la matrice de transformation en pixels pour l'image fournie,</p></li>
<li><p><code class="docutils literal notranslate"><span class="pre">publish_annoted_image(self)</span></code> : permet de publier l'image annotée avec les correspondances SIFT trouvées,</p></li>
<li><p><code class="docutils literal notranslate"><span class="pre">handle_request(self, req)</span></code> : permet de gérer les requêtes du service de localisation.</p></li>
</ul>
</li>
<li><p><h6>Les étapes principales sont :</h6></p>
<ul>
<li><p>Initialisation : Lorsque le script démarre, il initialise les paramètres nécessaires et configure le noeud ROS associé.</p></li>
<li><p>Service de localisation : Lorsque le service <code class="docutils literal notranslate"><span class="pre">compute_localization</span></code> reçoit une requête avec une image (issue de la caméra), le script convertit l'image, détecte les points clés avec SIFT, calcule la transformation de l'image modèle vers l'image capturée par la caméra, et retourne la pose correspondante.</p></li>
<li><p>Publication d'images annotées : Les images annotées montrant les correspondances SIFT sont publiées sur le topic <code class="docutils literal notranslate"><span class="pre">/SIFT_localization</span></code>.</p></li>
<li><p>Boucle ROS : La méthode "<code class="docutils literal notranslate"><span class="pre">run</span></code>" assure que le noeud reste actif et répond aux requêtes tant que ROS est en cours d'exécution.</p></li>
</ul>
</li>
</ul>
</li>
</div>
</ul>

</section>
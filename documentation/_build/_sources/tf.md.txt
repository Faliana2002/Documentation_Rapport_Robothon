# Définition de TFs au niveau de l'effecteur final

<style>
    .image{
    border: 5px solid #116aa4;
    border-radius: 10px;
    /* padding: 2px; */
    }
</style>

## Les TFs définies au niveau de l'effecteur final

Pour faciliter la réalisations de la plupart des tâches complexes, on a décidé de définir des TFs (à l'aide de la fonction `tf_static_publisher` dans le launchfile superviseur "*franka_positions.launch*") au niveau de l'effecteur final. Ces TFs sont les suivantes : (à rappeler que l'axe des <strong><span class="redlight">x</span></strong> est représenté en rouge, l'axe des <strong><span class="greenlight">y</span></strong> en vert et l'axe des <strong><span class="bluelight">z</span></strong> en bleu)

- On a défini une première TF au niveau de l'effecteur final qui se placera dans la vraie vie au niveau du bout des deux pinces, pile au milieu des deux grippeurs, la TF en question se nomme : "`tool`",

<table align="center">
  <tr>
    <th>
      <div class="image">
        <img src="./img/new/tool.png"/>
      </div>
    </th>
  </tr>
</table>

```{mermaid}
---
caption: Position de la TF "`tool`" par rapport à l'effecteur final
align: 'center'
---
graph LR

```

- Pour attraper la sonde, on a défini une TF qui s'appelle "`tool_probe`" et qui suit l'inclinaison de la cavité au niveau de la pince pour faciliter non seulement la saisie de la sonde mais aussi pour obtenir une trajectoire optimale pour la récupération de la sonde puis le prélèvement au niveau du capteur situé en dessous la trappe,

<table align="center">
  <tr>
    <th>
      <div class="image">
        <img src="./img/new/tool_probe.png"/>
      </div>
    </th>
  </tr>
</table>

```{mermaid}
---
caption: Position de la TF "`tool_probe`" par rapport à l'effecteur final
align: 'center'
---
graph LR

```

- Pour pouvoir agripper correctement le poignée de la trappe pour son ouverture, on a donc aussi créé une TF : "`tool_door`" qui suivra l'angle d'inclinaison de l'évidemment au niveau des deux pinces, passé de 45° à 35° pour améliorer la prise du poignée, mais surtout le relachement lorsque la trappe est bien ouverte et que le bras de robot devra arrếter d'agripper le poignée (pas mal d'essais ont été réalisés pour éviter d'endommager au maximum la task-board mais surtout la trappe),

<table align="center">
  <tr>
    <th>
      <div class="image">
        <img src="./img/new/tool_door.png"/>
      </div>
    </th>
  </tr>
</table>

```{mermaid}
---
caption: Position de la TF "`tool_door`" par rapport à l'effecteur final
align: 'center'
---
graph LR

```

- Pour une tâche comme le déplacement du connecteur de la sonde d'un port à un autre, on a défini une TF "`tool_opp`" pour adapter l'orientation de l'effecteur (par rapport aux TFs) par rapport aux différentes orientations de la task-board (qui est aléatoire), pour éviter des positions limites.

<table align="center">
  <tr>
    <th>
      <div class="image">
        <img src="./img/new/tool_opp.png"/>
      </div>
    </th>
  </tr>
</table>

```{mermaid}
---
caption: Position de la TF "`tool_opp`" par rapport à l'effecteur final
align: 'center'
---
graph LR

```
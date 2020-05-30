# onset_collision_prophunt

## Basics of prophunt

All players must be connected before the Props transform in order to see them correctly. <br>

By default :<br>
 - **Num 1** : Change team Props<br>
 - **Num 2** : Change team Hunter<br>
 - **F** : Reset object<br>
 - **Left Click** : Take object<br>
 - **Left Ctrl** : Lock Camera<br>
 To make testing easier, I've linked these actions on keys, but you'll obviously have to link them on event or interface.<br>
 
## Issues
 Concerning the Props transformation its work only on objects that are positioned from their lowest point **(ex objectId: 503,504,513,...)**<br>
 For all objects that are positioned from their center of gravity **(ex objectId: 1,2,157,340,341,...)** you have to delete the divison by 2 on [this line](https://github.com/Hazard4U/onset_collision_prophunt/blob/87748a8997c6bdf3167012ec67c446edafccc42f/server/s_prop.lua#L41) and [this line](https://github.com/Hazard4U/onset_collision_prophunt/blob/87748a8997c6bdf3167012ec67c446edafccc42f/server/s_prop.lua#L43)<br>
 Make a list of all the objects that are in this case and adapt the calculation
 
 ## Suggestions
 - Use a script to handle undermap issue<br>
 - Feel free to update and improve this core to grow the Onset community.
 
 

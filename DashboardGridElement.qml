import QtQuick
import Blockwars24

GameScene {
    id: gridRoot
    /* _blocks is a multidimensional array of Block instances */
    property var _blocks
    property var blockPool
    property var powerupDataStore

    function addBlock(row, col) {
       var blockColor = blockPool.getNextColor()
       /* create instance of Block.qml and assign block color, default HP */
       /* set block state to "willDrop" and its position to where row # (row - 6) would be so if its going to be in row 5, then set it to row -1's postion for (x, y) values */
        /* add block to the _blocks array like _blocks[row][col] = <Block instance> */

    }

    function setGridState(newState) {
     /* modifies the grid state -- goes from idle to switchAnimRunning to switchAnimFinished to matchSearching to matchSearchingFinished
       to matchAnimRunning to matchAnimFinished to launchAnimRunning to launchAnimFinished to compactAnimRunning to compactAnimFinished
       to matchSearching to matchSearchingFinished to <either matchAnimRunning or boardSettled> to <if boardSettled: either idle or waiting depending on if switchesRemaining is greater than 0>

       also has powerupAnimRunning and powerAnimFinished which then goes into compactAnimRunning or waiting depending on if this board is on offense or defense

       waiting means no blocks move or change state */
    }

    function generateBlockData() {
        /* generates data by pulling properties from all Blocks in _blocks
          and creates an array like this
         [[{color: "red", hp: 25, isPowerup: false, powerupUuid: "", blockState: "matchAnimRunning", row: 0, column: 0},{color: "red", hp: 25, isPowerup: false, powerupUuid: "", blockState: "willLaunch", row: 0, column: 1}, {color: "green", hp: 25, isPowerup: false, powerupUuid: "", blockState: "idle", row: 0, column: 2},null,null,null,...],[...row 2 blocks],...]
       */
    }
}

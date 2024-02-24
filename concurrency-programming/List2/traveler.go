package main

import (
	"fmt"
	"math/rand"
	"sync"
)

type Traveler struct {
  mu sync.Mutex
  id int
  x, y int
}

func (t *Traveler) move(grid *[][] Node) { // function for moving the traveler
  directions := [][2]int{{-1, 0}, {1, 0}, {0, -1}, {0, 1}}
  for { // nieskończona pętla
    var move = directions[rand.Intn(4)]
    var oldX, oldY = t.x, t.y
    var newX, newY = t.x + move[0], t.y + move[1] // new coordinates
    if(newX >= 0 && newX < m && newY >= 0 && newY < n) { // valid coordinates
      (*grid)[newX][newY].requests <- Request{ t: t, l: nil, threat: nil, move: move, leave: false, isMove: true } // sending request to Node with new coordinates
      var response = <- (*grid)[newX][newY].responses
      if response.allowed {
        // deleting traveler from old coordinates
        (*grid)[oldX][oldY].requests <- Request{ t: t, l: nil, threat: nil, move: move, leave: true, isMove: false } 
        <- (*grid)[oldX][oldY].responses
        return
      } else if response.destroy {
        (*grid)[oldX][oldY].requests <- Request{ t: t, l: nil, threat: nil, move: [2]int{0, 0}, leave: true, isMove: false }
        <- (*grid)[oldX][oldY].responses
        fmt.Printf("Traveler of id %d na starej pozycji to %d", (*grid)[oldX][oldY].traveler); 
        fmt.Printf("Zniszczono travelera o id %d na pozycji (%d, %d)\n", t.id, oldX, oldY)
        return
      }
    }
  }
}
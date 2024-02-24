package main

import (
	"fmt"
	"time"
)

type Threat struct {
  id int
  z time.Duration // czas istnienia z, po którym znika
  x, y int // współrzędne wierzchołka, w którym znajduje się to zagrozenie
  isAlive chan struct{}
}

func (threat *Threat) appear(grid *[][] Node) {

}

func (threat *Threat) monitorLifespan(grid *[][]Node) {
  select {
  case <-time.After((*threat).z):
    fmt.Printf("Threat %d lifespan ended\n", threat.id)
    (*grid)[threat.x][threat.y].requests <- Request{ t: nil, l: nil, threat: threat, move: [2]int{0, 0}, leave: true, isMove: false}
    response := <-(*grid)[threat.x][threat.y].responses
    if response.allowed {
      close(threat.isAlive)
      return
    }
    
  case <-threat.isAlive: // zakonczenie monitorowania czasu zycia zagrozenia
    close(threat.isAlive)
    return
  }
}

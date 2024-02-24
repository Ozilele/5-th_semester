package main

import (
	"fmt"
	"time"
)


type Locator struct {
  id int
	lifespan time.Duration // czas zycia(w ms)
	x, y int // miejsce w wierzchołku
  isDead chan struct{} // kanał do sygnalizacji kiedy lokator znika
}

func (l *Locator) monitorLifespan(grid *[][]Node) {
  select {
  case <-time.After((*l).lifespan):
    fmt.Printf("Locator %d lifespan ended\n", l.id)
    (*grid)[l.x][l.y].requests <- Request{ t: nil, l: l, threat: nil, move: [2]int{0, 0}, leave: true, isMove: false}
    response := <-(*grid)[l.x][l.y].responses
    if response.allowed {
      close(l.isDead)
    }
  }
}
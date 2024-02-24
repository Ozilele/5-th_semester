package main

type myMutex struct {
	chanel chan struct{}
}

func (m *myMutex) Lock() {
	if m.chanel == nil {
		m.chanel = make(chan struct{}, 1)
	}
	m.chanel <- struct{}{}
}

func (m *myMutex) Unlock() {
	if m.chanel != nil {
		<-m.chanel
	}
}

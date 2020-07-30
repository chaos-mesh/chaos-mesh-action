package main

import (
	"flag"
	"fmt"
	"os"
)

func main() {
	cfg := NewConfig()
	err := GenerateConfigFile(cfg.ChaosType)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}

// GenerateConfigFile generates config file for chaos mesh
func GenerateConfigFile(tp string) error {
	fileName := "chaos.yaml"
	f, err := os.Create(fileName)
	if err != nil {
		return err
	}
	defer f.Close()

	cfgContent := `
	apiVersion: pingcap.com/v1alpha1
	kind: NetworkChaos
	metadata:
	  name: web-show-network-delay
	spec:
	  action: delay # the specific chaos action to inject
	  mode: one # the mode to run chaos action; supported modes are one/all/fixed/fixed-percent/random-max-percent
	  selector: # pods where to inject chaos actions
		namespaces:
		  - default
		labelSelectors:
		  "app": "nginx"  # the label of the pod for chaos injection
	  delay:
		latency: "10ms"
	  duration: "30s" # duration for the injected chaos experiment
	  scheduler: # scheduler rules for the running time of the chaos experiments about pods.
		cron: "@every 60s"
	`

	switch tp {
	case "NetworkChaos":
		_, err = f.WriteString(cfgContent)
		if err != nil {
			return err
		}
	}

	return nil
}

// Config saves some informations about chaos test
type Config struct {
	*flag.FlagSet

	ChaosType string
}

// NewConfig returns Config by flag
func NewConfig() *Config {
	cfg := &Config{}
	cfg.FlagSet = flag.NewFlagSet("chaos-mesh-actions", flag.ContinueOnError)
	fs := cfg.FlagSet

	fs.StringVar(&cfg.ChaosType, "chaos-type", "", "chaos type")

	return cfg
}

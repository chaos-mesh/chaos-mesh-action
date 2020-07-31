package main

import (
	"flag"
	"fmt"
	"os"
)

func main() {
	cfg := NewConfig()
	err := cfg.Parse(os.Args[1:])
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
	if !cfg.Verify() {
		fmt.Println("config is invalid, please check it")
		os.Exit(1)
	}

	err = GenerateConfigFile(cfg)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}

// GenerateConfigFile generates config file for chaos mesh
func GenerateConfigFile(cfg *Config) error {
	fileName := "chaos.yaml"
	f, err := os.Create(fileName)
	if err != nil {
		return err
	}
	defer f.Close()

	cfgContent := `
apiVersion: chaos-mesh.org/v1alpha1
kind: %s
metadata:
  name: web-show-network-delay
spec:
  action: delay # the specific chaos action to inject
  mode: one # the mode to run chaos action; supported modes are one/all/fixed/fixed-percent/random-max-percent
  selector: # pods where to inject chaos actions
    namespaces:
      - default
    labelSelectors:
      "app": "%s"  # the label of the pod for chaos injection
    delay:
      latency: "10ms"
    duration: "%ds" # duration for the injected chaos experiment
    scheduler: # scheduler rules for the running time of the chaos experiments about pods.
      cron: "@every 60s"`

	switch cfg.ChaosKind {
	case "NetworkChaos":
		_, err = f.WriteString(fmt.Sprintf(cfgContent, cfg.ChaosKind, cfg.AppName, cfg.Duration))
		if err != nil {
			return err
		}
	}

	return nil
}

// Config saves some informations about chaos test
type Config struct {
	*flag.FlagSet

	ChaosKind string
	AppName   string
	Duration  int64
}

// NewConfig returns Config by flag
func NewConfig() *Config {
	cfg := &Config{}
	cfg.FlagSet = flag.NewFlagSet("chaos-mesh-actions", flag.ContinueOnError)
	fs := cfg.FlagSet

	fs.StringVar(&cfg.ChaosKind, "chaos-type", "", "chaos type")
	fs.StringVar(&cfg.AppName, "app-name", "", "applition name")
	fs.Int64Var(&cfg.Duration, "duration", 10, "chaos duration")

	return cfg
}

// Parse parses flag definitions from the argument list.
func (c *Config) Parse(arguments []string) error {
	// Parse first to get config file.
	err := c.FlagSet.Parse(arguments)
	if err != nil {
		return err
	}

	return nil
}

// Verify verifies the config is valide or not
func (c *Config) Verify() bool {
	if len(c.ChaosKind) == 0 {
		return false
	}

	if len(c.AppName) == 0 {
		return false
	}

	if c.Duration == 0 {
		return false
	}

	return true
}

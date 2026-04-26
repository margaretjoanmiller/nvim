-- gopls: Go language server
-- Source: https://pkg.go.dev/golang.org/x/tools/gopls
return {
	settings = {
		gopls = {
			gofumpt = true,
			analyses = {
				unusedparams = true,
				shadow = true,
				nilness = true,
				unusedwrite = true,
				useany = true,
			},
			staticcheck = true,
			usePlaceholders = true,
			completeUnimported = true,
			hints = {
				assignVariableTypes = true,
				compositeLiteralFields = true,
				compositeLiteralTypes = true,
				constantValues = true,
				functionTypeParameters = true,
				parameterNames = true,
				rangeVariableTypes = true,
			},
			codelenses = {
				gc_details = false,
				generate = true,
				regenerate_cgo = true,
				run_govulncheck = true,
				test = true,
				tidy = true,
				upgrade_dependency = true,
				vendor = true,
			},
		},
	},
}

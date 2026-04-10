using Azure.Identity;
using Azure.Security.KeyVault.Secrets;

namespace Api.Configuration;

public static class KeyVaultConfiguration
{
    /// <summary>
    /// Loads all secrets directly from Azure Key Vault.
    /// Vault name is read from KeyVault:VaultName in appsettings.json.
    /// Throws on startup if the vault name is missing or the vault is unreachable.
    /// No fallback — all secrets must come from Key Vault.
    /// Skipped only in the Testing environment (integration test host).
    /// </summary>
    public static void AddKeyVault(this IConfigurationBuilder config, IWebHostEnvironment env)
    {
        if (env.IsEnvironment("Testing")) return;

        var snapshot = config.Build();

        var vaultName = snapshot["KeyVault:VaultName"];
        if (string.IsNullOrWhiteSpace(vaultName))
            throw new InvalidOperationException(
                "KeyVault:VaultName is not set in appsettings.json. " +
                "The application requires Azure Key Vault to start.");

        var vaultUri = new Uri($"https://{vaultName}.vault.azure.net/");
        var credential = new DefaultAzureCredential();

        EnsureVaultReachable(vaultUri, credential);

        config.AddAzureKeyVault(vaultUri, credential);
    }

    private static void EnsureVaultReachable(Uri vaultUri, DefaultAzureCredential credential)
    {
        try
        {
            var client = new SecretClient(vaultUri, credential);
            client.GetPropertiesOfSecrets().AsPages(pageSizeHint: 1).FirstOrDefault();
        }
        catch (Exception ex)
        {
            throw new InvalidOperationException(
                $"Cannot connect to Azure Key Vault at '{vaultUri}'. " +
                $"Verify the vault exists and the identity has 'Key Vault Secrets User' role. " +
                $"Inner error: {ex.Message}", ex);
        }
    }
}

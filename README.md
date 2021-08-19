## Readme

#### Preconditions

- Have a account that has some DEER token （You need some DEER to apply validator on-chain）
- One Linux server with 32 GB memory and 500GB hard disk
- A browser with Polkadot{.js} extension, such as Chrome，Firefox

#### Install the deer Scripts

Go to the **deer** folder

```bash
chmod +x install.sh
sudo ./install.sh
```

#### Config deer node

> For testnet, Run `sudo deer network testnet`

```bash
sudo deer config set
```

#### Start deer node

```bash
sudo deer start
```
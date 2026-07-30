# voices38-pragmata.iso

Download every `voices38-pragmata.iso.part###` file, then combine them in numeric order.

Windows:

```powershell
copy /b voices38-pragmata.iso.part* voices38-pragmata.iso
```

macOS/Linux:

```bash
cat voices38-pragmata.iso.part* > voices38-pragmata.iso
```

After combining, compare the SHA256 hash with `SHA256SUMS.txt`.

